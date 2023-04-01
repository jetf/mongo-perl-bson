use 5.010001;
use strict;
use warnings;
use utf8;

use JSON ();
use Test::More;

use_ok('BSON');

sub cmp_extjson {
  my ($perl, $extjson) = (shift,shift);
  is_deeply(
    eval { BSON->perl_to_extjson($perl,{'relaxed'=>$ENV{'BSON_EXTJSON_RELAXED'}}) } // $@,
    $extjson,
    'relaxed=' . ($ENV{'BSON_EXTJSON_RELAXED'}?1:0) . ', ' . JSON::encode_json($extjson)
  );
}

my @ext_tests = (
  # each test has a different key: 'a', 'b', ..., 'A', 'B', ...
  # perl                                                  extjson
  [ Tie::IxHash->new('a'=>'x'),                           {'a'=>'x'}                  ],
  [ {'b' => Tie::IxHash->new('c'=>'y','d'=>[])},          {'b' => {'c'=>'y','d'=>[]}} ],
  [ {'c' => ['d'=>Tie::IxHash->new()]},                   {'c' => ['d', {}]}          ],
  [ {'d' => do{tie my %h, 'Tie::IxHash', 'e'=>'f'; \%h}}, {'d' => {'e'=>'f'}}  ],
  [ BSON::Doc->new('A'=>'X'),                             {'A'=>'X'}                  ],
  [ BSON::Doc->new('B'=>BSON::Doc->new('C'=>'Y','D'=>[])),{'B' => {'C'=>'Y','D'=>[]}} ],
  [ BSON::Doc->new('C'=>['D'=>BSON::Doc->new()]),         {'C' => ['D', {}]}          ],
  [ BSON::Doc->new('D'=>BSON::Doc->new('E'=>'F')),        {'D' => {'E'=>'F'}}         ],
);

for my $i (0..1) {
  local $ENV{'BSON_EXTJSON_RELAXED'} = $i;
  cmp_extjson(@$_) for @ext_tests;
};

done_testing