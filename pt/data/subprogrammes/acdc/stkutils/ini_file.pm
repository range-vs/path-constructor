package stkutils::ini_file;

use strict;
use IO::File;
use stkutils::debug 'fail';
#use Tie::IxHash;
sub new {
	my $class = shift;
	my ($fn, $mode) = @_;

	my $fh = IO::File->new($fn, $mode) or return undef;

	my $self = {};
	$self->{fh} = $fh;
	$self->{sections_list} = [];
	$self->{sections_hash} = ();
	bless($self, $class);

	$mode eq 'w' and return $self;

	my $section;
	my $skip_section = 0;
	while (<$fh>) {
		$_ =~ qr/^\s*;/ and next;
		if (/^\[(.*)\]\s*:*\s*(\w.*)?/) {
			if (defined $2 && !::is_flag_defined($2)) {
				$skip_section = 1;
				next;
			}
			$section = $1;
			fail(__PACKAGE__.'::new', __LINE__, 'defined $self->{sections_hash}->{$section}', 'duplicate section found while reading '.$fn) if defined $self->{sections_hash}->{$section};
			push @{$self->{sections_list}}, $section;
			my %tmp = ();
#			tie %tmp, "Tie::IxHash";
			$self->{sections_hash}{$section} = \%tmp;
			$skip_section = 0;
#			print "\n[$section]\n";
#			die if $section == 102;
			next;
		}
		if (/^\s*([^=]*?)\s*=\s*(.*?)$/) {
			my ($name, $value) = ($1, $2);
			if ($value =~ /^<<(.+)$/) {
				my $terminator = $1;
				$value = '';
				while (<$fh>) {
					chomp;
					last if $_ eq $terminator;
					$value .= "\n".$_;
#					print $_."\n";
				}
				die unless defined $_;
				substr ($value, 0, 1) = '';
			}
			$skip_section == 1 and next;
			fail(__PACKAGE__.'::new', __LINE__, 'defined $section', 'undefined section found while reading '.$fn) unless defined $section;
			if (($name ne 'custom_data') and $value =~ /^(.+)(?=\s*;+?)/) {
				$value = $1;
			}
#			print "$name = $value\n";
			$self->{sections_hash}{$section}{$name} = $value;
		}
	}
	return $self;
}
sub close {
	my $self = shift;
	$self->{fh}->close();
	$self->{fh} = undef;
}
use constant format_for_number => {
	h32	=> '%#x',
	h16	=> '%#x',
	h8	=> '%#x',
	u32	=> '%u',
	u16	=> '%u',
	u8	=> '%u',
	q8	=> '%.8g',
	q16	=> '%.8g',
	q16_old	=> '%.8g',
	s32	=> '%d',
	s16	=> '%d',
	s8	=> '%d',
	f32	=> '%.8g',
};
sub export_properties {
	my $self = shift;
	my $comment = shift;
	my $container = shift;

	my $fh = $self->{fh};

	print $fh "\n; $comment properties\n" if defined $comment;
	foreach my $p (@_) {
#	print "$p->{name}, $p->{type}\n";
		my $format = format_for_number->{$p->{type}};
		if ($p->{type} eq 'f32' or $p->{type} eq 'q8') {
			next if defined($p->{default}) && abs($container->{$p->{name}} - $p->{default}) < 0.001;
			print $fh "$p->{name} = $container->{$p->{name}}\n";
		} elsif (defined $format) {
			fail(__PACKAGE__.'::export_properties', __LINE__, 'defined $container->{$p->{name}}', 'undefined field '.$p->{name}) unless defined $container->{$p->{name}};
			next if defined($p->{default}) && $container->{$p->{name}} == $p->{default};
			printf $fh "$p->{name} = $format\n", $container->{$p->{name}};
		} elsif ($p->{type} eq "sz") {
			next if defined($p->{default}) && $container->{$p->{name}} eq $p->{default};
			my $value = $container->{$p->{name}};
			if ($value =~ /\n/) {
				print $fh "$p->{name} = <<END\n$value\nEND\n";
			} else {
				print $fh "$p->{name} = $value\n";
			}
		} elsif ($p->{type} eq 'shape') {
			my @shapes;
			my $i = 0;
			foreach my $shape (@{$container->{$p->{name}}}) {
				push @shapes, "shape$i";
				$i++;
			}
			print $fh 'shapes = ', join(',', @shapes), "\n";
			$i = 0;
			foreach my $shape (@{$container->{$p->{name}}}) {
				my $id = "shape$i";
				if ($$shape{type} == 0) {
					print $fh "$id:type = sphere\n";
					print $fh "$id:offset = ", join(',', @{$$shape{sphere}}[0 .. 2]), "\n";
					print $fh "$id:radius = $$shape{sphere}[3]\n";
				} elsif ($$shape{type} == 1) {
					print $fh "$id:type = box\n";
					print $fh "$id:axis_x = ", join(',', @{$$shape{box}}[0 .. 2]), "\n";
					print $fh "$id:axis_y = ", join(',', @{$$shape{box}}[3 .. 5]), "\n";
					print $fh "$id:axis_z = ", join(',', @{$$shape{box}}[6 .. 8]), "\n";
					print $fh "$id:offset = ", join(',', @{$$shape{box}}[9 .. 11]), "\n";
				}
				$i++;
			}
		} elsif ($p->{type} eq 'supplies') {
			next if @{$container->{$p->{name}}}[0] eq 'none';
			my @supplies;
			my $i = 0;
			foreach my $sect (@{$container->{$p->{name}}}) {
				push @supplies, "section_$i";
				$i++;
			}
			print $fh 'supplies = ', join(',', @supplies), "\n";
			$i = 0;
			foreach my $sect (@{$container->{$p->{name}}}) {
				my $id = "section_$i";
				print $fh "$id:section_name = $sect->{section_name}\n";
				print $fh "$id:item_count = $$sect{item_count}\n";
				print $fh "$id:min_factor = $$sect{min_factor}\n";
				print $fh "$id:max_factor = $$sect{max_factor}\n";
				print $fh "\n";
				$i++;
			}
		} elsif ($p->{type} eq 'afspawns') {
			next if @{$container->{$p->{name}}}[0] eq 'none';
			my @supplies;
			my $i = 0;
			foreach my $sect (@{$container->{$p->{name}}}) {
				push @supplies, "artefact_section_$i";
				$i++;
			}
			print $fh 'artefact_spawns = ', join(',', @supplies), "\n";
			$i = 0;
			foreach my $sect (@{$container->{$p->{name}}}) {
				my $id = "artefact_section_$i";
				print $fh "$id:section_name = $$sect{section_name}\n";
				print $fh "$id:weight = $$sect{weight}\n";
				print $fh "\n";
				$i++;
			}
		} elsif ($p->{type} eq 'afspawns_u32') {
			next if @{$container->{$p->{name}}}[0] eq 'none';
			my @supplies;
			my $i = 0;
			foreach my $sect (@{$container->{$p->{name}}}) {
				push @supplies, "artefact_section_$i";
				$i++;
			}
			print $fh 'artefact_spawns_old_format = ', join(',', @supplies), "\n";
			$i = 0;
			foreach my $sect (@{$container->{$p->{name}}}) {
				my $id = "artefact_section_$i";
				print $fh "$id:section_name = $$sect{section_name}\n";
				print $fh "$id:weight = $$sect{weight}\n";
				print $fh "\n";
				$i++;
			}
		} elsif ($p->{type} eq 'ordaf') {
			my @ord_afs;
			my $i = 0;
			my $k = 0;
			next if @{$container->{$p->{name}}}[0] eq 'none';
			foreach my $sect (@{$container->{$p->{name}}}) {
				push @ord_afs, "unknown_section_$i";
				$i++;
			}
			print $fh 'unknown_sections = ', join(',', @ord_afs), "\n";
			$i = 0;
			foreach my $sect (@{$container->{$p->{name}}}) {
				my @af_sections;
				my $id = "unknown_section_$i";
				print $fh "$id:unknown_string = $sect->{name}\n";
				print $fh "$id:unknown_number = $sect->{number}\n";
				foreach  my $af (@{$sect->{af_sects}}) {
					push @af_sections, "unknown_section_$i";
					$k++;
				}
				print $fh 'artefact_sections = ', join(',', @af_sections), "\n";
				$k = 0;
				foreach my $af (@{$sect->{af_sects}}) {
					my $af_id = "artefact_section_$i";
					print $fh "$id:$af_id:artefact_name = $af->{af_section}\n";
					print $fh "$id:$af_id:number_1 = $af->{unk_num1}\n";
					print $fh "$id:$af_id:number_2 = $af->{unk_num2}\n";
					$k++;
				}
				$i++;
			}
		} else {
			next if (defined(@{$p->{default}}) && comp_arrays($container, $p));
			print $fh "$p->{name} = ", join(', ', @{$container->{$p->{name}}}), "\n";
		}
	}
#	print $fh "\n" unless (not (defined $comment));
}
sub import_properties {
	my $self = shift;
	my $section = shift;
	my $container = shift;

	fail(__PACKAGE__.'::import_properties', __LINE__, 'defined $self->{sections_hash}{$section}', "$section is undefined") unless defined $self->{sections_hash}{$section};
#	print "[$section]\n";
	foreach my $p (@_) {
#	print "$p->{name} = ";
		my $value = $self->value($section, $p->{name});
		if ($p->{type} eq 'sz') {
			$container->{$p->{name}} = (defined $value) ? $value : $p->{default};
		} elsif (defined format_for_number->{$p->{type}}) {
			if (defined $value) {
				$value = hex($value) if ($value =~ /^\s*0x/);
				$container->{$p->{name}} = $value;
			} else {
				$container->{$p->{name}} = $p->{default};
			}
		} elsif ($p->{type} eq 'shape') {
			die unless defined $value;
			foreach my $id (split /,/, $value) {
				$id =~ s/^\s*|\s*$//g;
				my $shape = $self->import_shape_properties($section, $id);
				push @{$container->{$p->{name}}}, $shape;
			}
		} elsif ($p->{type} eq 'supplies') {
			if (!defined $value or $value eq 'none') {
				@{$container->{$p->{name}}} = 'none';
				next;
			}
			foreach my $id (split /,/, $value) {
				$id =~ s/^\s*|\s*$//g;
				my $sect = $self->import_suppl_properties($section, $id);
				push @{$container->{$p->{name}}}, $sect;
			}
		} elsif ($p->{type} eq 'afspawns' or $p->{type} eq 'afspawns_u32') {
			if (!defined $value or $value eq 'none') {
				@{$container->{$p->{name}}} = 'none';
				next;
			}
			foreach my $id (split /,/, $value) {
				$id =~ s/^\s*|\s*$//g;
				my $sect = $self->import_afspawns_properties($section, $id);
				push @{$container->{$p->{name}}}, $sect;
			}
		} elsif ($p->{type} eq 'ordaf') {
			if (!defined $value or $value eq 'none') {
				@{$container->{$p->{name}}} = 'none';
				next;
			}
			foreach my $id (split /,/, $value) {
				$id =~ s/^\s*|\s*$//g;
				my $sect = $self->import_ordaf_properties($section, $id);
				push @{$container->{$p->{name}}}, $sect;
			}
		} else {
			@{$container->{$p->{name}}} = defined $value ?
					split(/,\s*/, $value) : @{$p->{default}};
		}
#		print $value."\n";
	}
}
sub import_shape_properties {
	my $self = shift;
	my ($section, $id) = @_;

	my %shape;

	my $type = $self->value($section, "$id:type") or fail(__PACKAGE__.'::import_shape_properties', __LINE__, '$self->value($section, "$id:type")', 	"no type in $section\n");
	my $offset = $self->value($section, "$id:offset");
	if ($type eq "sphere") {
		my $radius = $self->value($section, "$id:radius") or fail(
			__PACKAGE__.'::import_shape_properties', 
			__LINE__, 
			'$self->value($section, "$id:radius")',
			"no radius in $section\n");
		$shape{type} = 0;
		@{$shape{sphere}} = (split(/,/, $offset), $radius);
	} elsif ($type eq "box") {
		$shape{type} = 1;
		my $axis_x = $self->value($section, "$id:axis_x") or fail(
			__PACKAGE__.'::import_shape_properties', 
			__LINE__, 
			'$self->value($section, "$id:axis_x")',
			"no axis_x in $section\n");
		my $axis_y = $self->value($section, "$id:axis_y") or fail(
			__PACKAGE__.'::import_shape_properties', 
			__LINE__, 
			'$self->value($section, "$id:axis_y")',
			"no axis_y in $section\n");
		my $axis_z = $self->value($section, "$id:axis_z") or fail(
			__PACKAGE__.'::import_shape_properties', 
			__LINE__, 
			'$self->value($section, "$id:axis_z")',
			"no axis_z in $section\n");
		push @{$shape{box}}, split(/,/, $axis_x), split(/,/, $axis_y);
		push @{$shape{box}}, split(/,/, $axis_z), split(/,/, $offset);
	} else {
		fail(__PACKAGE__.'::import_shape_properties', __LINE__, '', "unknown shape type in $section\n");
	}
	return \%shape;
}
sub import_suppl_properties {
	my $self = shift;
	my ($section, $id) = @_;

	my %item;

	$item{section_name} = $self->value($section, "$id:section_name") or fail(
		__PACKAGE__.'::import_suppl_properties', 
		__LINE__,
		'$self->value($section, "$id:section_name")',
		"no section_name in $section\n");
	$item{item_count} = $self->value($section, "$id:item_count") or fail(
		__PACKAGE__.'::import_suppl_properties', 
		__LINE__,
		'$self->value($section, "$id:item_count")',
		"no item_count in $section\n");
	$item{min_factor} = $self->value($section, "$id:min_factor") or fail(
		__PACKAGE__.'::import_suppl_properties', 
		__LINE__,
		'$self->value($section, "$id:min_factor")',
		"no min_factor in $section\n");
	$item{max_factor} = $self->value($section, "$id:max_factor") or fail(
		__PACKAGE__.'::import_suppl_properties', 
		__LINE__,
		'$self->value($section, "$id:max_factor")',
		"no max_factor in $section\n");

	return \%item;
}
sub import_afspawns_properties {
	my $self = shift;
	my ($section, $id) = @_;

	my %item;

	$item{section_name} = $self->value($section, "$id:section_name") or fail(
		__PACKAGE__.'::import_afspawns_properties', 
		__LINE__, 
		'$self->value($section, "$id:section_name")',
		"no section name in $section\n");
	$item{weight} = $self->value($section, "$id:weight") or fail(
		__PACKAGE__.'::import_afspawns_properties', 
		__LINE__, 
		'$self->value($section, "$id:weight")',
		"no weight in $section\n");
	return \%item;
}
sub import_ordaf_properties {
	my $self = shift;
	my ($section, $id) = @_;

	my %item;
	$item{unknown_string} = $self->value($section, "$id:unknown_string") or die "no unknown_string in $section\n";
	$item{unknown_number} = $self->value($section, "$id:unknown_number") or die "no unknown_number in $section\n";
	foreach my $af_id (split /,/, $self->value($section, "artefact_sections")) {
		my $art = {};
		$af_id =~ s/^\s*|\s*$//g;
		
		$art->{artefact_name} = $self->value($section, "$id:$af_id:artefact_name") or die "no artefact_name in $section\n";
		$art->{number_1} = $self->value($section, "$id:$af_id:number_1") or die "no number_1 in $section\n";
		$art->{number_2} = $self->value($section, "$id:$af_id:number_2") or die "no number_2 in $section\n";
		push @{$item{af_sects}}, $art;
	}

	return \%item;
}
sub comp_arrays {
	my $container = shift;
	my ($prop) = @_;	
	return 0 if $#{$container->{$prop->{name}}} != $#{$prop->{default}};
	my ($i, $j) = (0, 0);
	foreach (@{$container->{$prop->{name}}}) {
		$j++;
		$i++ if abs($_ - $prop->{default}[$i]) < 0.0001;
		return 0 if $i != $j;
	}
	return 1;
}
sub value {
	my $self = shift;
	my ($section, $name) = @_;
	fail(
		__PACKAGE__.'::value', 
		__LINE__,
		'defined $self->{sections_hash}{$section}',
		"$section is undefined") unless defined $self->{sections_hash}{$section};
	return $self->{sections_hash}{$section}{$name};
}
sub is_value_exists {
	my $self = shift;
	my ($section, $name) = @_;
	return defined $self->{sections_hash}{$section}{$name};
}
sub is_section_exists {
	my $self = shift;
	my ($section) = @_;
	return defined $self->{sections_hash}{$section};
}

1;
