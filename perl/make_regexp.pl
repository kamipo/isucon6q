use strict;
use warnings;
use Regexp::Assemble;
use DBIx::Sunny;

my $db = DBIx::Sunny->connect('dbi:mysql:db=isuda', 'root', '');

my $keywords = $db->select_all(qq[
    SELECT * FROM entry ORDER BY length DESC
]);

my $ra = Regexp::Assemble->new;
for my $key (@$keywords) {
    $ra->add(quotemeta $key->{keyword});
}
print( $ra->as_string );
