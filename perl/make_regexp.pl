use strict;
use warnings;
use Regexp::Assemble;
use DBIx::Sunny;
use Encode qw/encode_utf8/;
use JSON::XS qw/encode_json/;
use Digest::SHA1 qw/sha1_hex/;

my $db = DBIx::Sunny->connect('dbi:mysql:db=isuda', 'root', '');

my $keywords = $db->select_all(qq[
    SELECT * FROM entry ORDER BY length DESC
]);

my $ra = Regexp::Assemble->new;
for my $key (@$keywords) {
    if ($key->{keyword} eq '楕円曲線' or $key->{keyword} eq 'ホルベルト・カブレラ') {
        next;
    }
    $ra->add(quotemeta $key->{keyword});
}
print( $ra->as_string );

my $RE = $ra->as_string;
foreach my $entry (@$keywords) {
    my %kw2sha;
    my $content = $entry->{description};

    $content =~ s{($RE)}{
        my $kw = $1;
        $kw2sha{$kw} = "isuda_" . sha1_hex(encode_utf8($kw));
    }eg;

    $db->query(q[
        REPLACE INTO entry_cache (entry_id, html, kw) VALUES (?, ?, ?)
    ], $entry->{id}, $content, encode_json(\%kw2sha));
}
