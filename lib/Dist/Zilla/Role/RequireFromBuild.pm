package Dist::Zilla::Role::RequireFromBuild;

# DATE
# VERSION

use 5.010001;
use Moose::Role;

sub require_from_build {
    require File::Temp;

    my ($self, $name) = @_;

    if ($name =~ /::/) {
        $name =~ s!::!/!g;
        $name .= ".pm";
    }

    my @files = grep { $_->name eq "lib/$name" } @{ $self->zilla->files };
    @files    = grep { $_->name eq $name }       $self->zilla->files
        unless @files;
    die "Can't find $name in lib/ or ./ in build files" unless @files;

    # write to temporary file, because the file object is not necessarily a
    # Dist::Zilla::File::OnDisk object or it is already munged so the file no
    # longer has the same content as the on-disk file.
    my ($fh, $filename) = File::Temp::tempfile();
    print $fh $files[0]->encoded_content;
    close $fh;
    do $filename;
}

no Moose::Role;
1;
# ABSTRACT: Role to require() from build files

=head1 SYNOPSIS

In your plugin's preamble, include the role:

 with 'Dist::Zilla::Role::RequireFromBuild';

Then in your plugin subroutine, e.g. C<munge_files()>:

 $self->require_from_build("Foo/Bar.pm");
 $self->require_from_build("Baz::Quux");


=head1 DESCRIPTION

C<require_from_build()> is like Perl's C<require()> except it looks for files
not from C<@INC> but from build files C<< $self->zilla->files >>. It searches
libraries in C<lib/> and C<.>.

C<< $self->require_from_build("Foo/Bar.pm") >> or C<<
$self->require_from_build("Foo::Bar") >> is a convenient shortcut for something
like:

 my @files = grep { $_->name eq "lib/Foo/Bar.pm" } @{ $self->zilla->files };
 @files    = grep { $_->name eq "Foo/Bar.pm" }     $self->zilla->files unless @files;
 die "Can't find Foo/Bar.pm in lib/ or ./ in build files" unless @files;

 # write to temporary file, because the file object is not necessarily a
 # Dist::Zilla::File::OnDisk object or it is already munged so the file
 # no longer has the same content as the on-disk file.
 require File::Temp;
 my ($fh, $filename) = File::Temp::tempfile();
 print $fh $files[0]->encoded_content;
 close $fh;
 do $filename;


=head1 METHODS

=head2 $obj->require_from_build($file)


=head1 SEE ALSO
