package MooseX::Types::LoadableClass;
# ABSTRACT: ClassName type constraint with coercion to load the class.
use strict;
use warnings;
use MooseX::Types -declare => [qw/ ClassName LoadableClass LoadableRole /];
use MooseX::Types::Moose qw(Str RoleName), ClassName => { -as => 'MooseClassName' };
use Moose::Util::TypeConstraints;
use Class::Load qw(is_class_loaded load_optional_class);
use namespace::autoclean;

subtype LoadableClass,
    as Str,
    where {
        is_class_loaded($_) || load_optional_class($_)
            and MooseClassName->check($_)
    };

subtype LoadableRole,
    as Str,
    where {
        is_class_loaded($_) || load_optional_class($_)
            and RoleName->check($_)
    };


# back compat
coerce LoadableClass, from Str, via { $_ };

coerce LoadableRole, from Str, via { $_ };

__PACKAGE__->type_storage->{ClassName}
    = __PACKAGE__->type_storage->{LoadableClass};

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 SYNOPSIS

    package MyClass;
    use Moose;
    use MooseX::Types::LoadableClass qw/ LoadableClass /;

    has foobar_class => (
        is => 'ro',
        required => 1,
        isa => LoadableClass,
    );

    MyClass->new(foobar_class => 'FooBar'); # FooBar.pm is loaded or an
                                            # exception is thrown.

=head1 DESCRIPTION

    use Moose::Util::TypeConstraints;

    my $tc = subtype as ClassName;
    coerce $tc, from Str, via { Class::Load::load_class($_); $_ };

I've written those three lines of code quite a lot of times, in quite
a lot of places.

Now I don't have to.

=head1 TYPES EXPORTED

=head2 LoadableClass

A normal class / package.

=head2 LoadableRole

Like C<LoadableClass>, except the loaded package must be a L<Moose::Role>.
