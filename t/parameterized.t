#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';
use Test::Moose;

use ok 'KiokuX::User';
use ok 'KiokuX::User::Util' => qw(crypt_password);

{
	package Foo::User;
	use Moose;

	with 'KiokuX::User' => {
        id_role_parameters       => { id_attribute       => 'identity' },
        password_role_parameters => { password_attribute => 'pass'     },
    };
}

my $o = Foo::User->new(
	identity => "bar",
	pass => crypt_password("foo"),
);

does_ok( $o, "KiokuX::User" );
does_ok( $o, "KiokuX::User::ID" );
does_ok( $o, "KiokuDB::Role::ID" );
does_ok( $o, "KiokuX::User::Password" );

is $o->identity, "bar", "user ID";
is $o->kiokudb_object_id, "user:bar", "object ID";

ok $o->check_password("foo"), "check pasword";

ok !$o->check_password("fo"), "bad password";

ok !$o->check_password(""), "bad password";

ok !$o->check_password("fooo"), "bad password";

is eval { $o->identity("lala") }, undef, "can't change ID";

$o->set_password("bar");

ok !$o->check_password("foo"), "password changed";

ok $o->check_password("bar"), "new password";

