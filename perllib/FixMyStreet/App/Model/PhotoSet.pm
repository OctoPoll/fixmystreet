package FixMyStreet::App::Model::PhotoSet;

# TODO this isn't a Cat model, rename to something else

use Moose;
use Path::Tiny 'path';

has c => (
    is => 'ro',
);

has data => ( # generic data from field
    is => 'ro',
);

has images => ( # jpeg data for actual image
    isa => 'ArrayRef',
    is => 'ro',
    traits => ['Array'],
    lazy => 1,
    handles => {
        num_images => 'count',
        get_raw_image_data => 'get',
    },
    default => sub {
        my $self = shift;
        my $data = $self->data
            or return [];
        if ($data =~ /^\x{ff}\x{d8}/) { # JPEG
            # NB: should we also handle \x{89}\x{50} (PNG, 15 results in live DB) ?
            #     and \x{49}\x{49} (Tiff, 3 results in live DB) ?
            return [$data];
        }
        my @photos = map 
            {
                my $part = $_;
                if (length($part) == 40) {
                    my $file = path( $self->c->config->{UPLOAD_DIR}, "$part.jpeg" );
                    my $photo = $file->slurp;
                    $photo;
                }
                else {
                    warn sprintf "Received photo hash of length %d", length($part);
                    ();
                }
            }
            split ',' => $data;
        return \@photos;
    },
);

sub get_image_data {
    my ($self, %args) = @_;
    my $num = $args{num} || 1;
    # my $data = $self->get_raw_image_data($num-1); # should work, but doesn't???
    #
    # my $dummy = $self->num_images; # force lazy attribute
    my $data = $self->get_raw_image_data( 0 ); # for test 

    return $data;
}

1;
