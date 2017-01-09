package Dist::Zilla::Role::RequireFromBuild;

# DATE
# VERSION

use 5.010001;
use Moose::Role;

sub require_from_build {
    my ($self, $name) = @_;

    if ($name =~ /::/) {
        $name =~ s!::!/!g;
        $name .= ".pm";
    }

    return if exists $INC{$name};

    my @files = grep { $_->name eq "lib/$name" } @{ $self->zilla->files };
    @files    = grep { $_->name eq $name }       @{ $self->zilla->files }
        unless @files;
    die "Can't find $name in lib/ or ./ in build files" unless @files;

    my $file = $files[0];
    my $filename = $file->name;
    eval "# line 1 \"$filename (from dist build)\"\n" . $file->encoded_content;
    die if $@;
    $INC{$name} = "(set by ".__PACKAGE__.", from build files)";
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

Since build files are not necessarily on-disk files, but might also be in-memory
files or files with munged content, we cannot use C<require()> directly.
C<require_from_build()> is like Perl's C<require()> except it looks for files
not from C<@INC> but from build files C<< $self->zilla->files >>. It searches
libraries in C<lib/> and C<.>.

C<< $self->require_from_build("Foo/Bar.pm") >> or C<<
$self->require_from_build("Foo::Bar") >> is a convenient shortcut for something
like:

 return if exists $INC{"Foo/Bar.pm"};

 my @files = grep { $_->name eq "lib/Foo/Bar.pm" } @{ $self->zilla->files };
 @files    = grep { $_->name eq "Foo/Bar.pm" }     @{ $self->zilla->files } unless @files;
 die "Can't find Foo/Bar.pm in lib/ or ./ in build files" unless @files;

 eval $files[0]->encoded_content;
 die if $@;

 $INC{"Foo/Bar.pm"} = "(set by Dist::Zilla::Role::RequireFromBuild, loaded from build file)";


=head1 METHODS

=head2 $obj->require_from_build($file)


=head1 SEE ALSO
