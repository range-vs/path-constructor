# SLOW!!!
package stkutils::data_packet;
use strict;
use IO::File;
use stkutils::debug 'fail';
use stkutils::ini_file;
use constant FL_IS_25XX => 0x08;
sub new {
	my $class = shift;
	my $data = shift;
	my $self = {};
	$self->{data} = '';
	$self->{data} = $$data if defined $data;
	$self->{init_length} = CORE::length($self->{data});
	$self->{pos} = 0;
	bless($self, $class);
	return $self;
}
sub unpack {
	my $self = shift;
	my $template = shift;
	my ($len) = @_;
fail(__PACKAGE__.'::unpack', __LINE__, 'defined $self', "packet is not defined") if !(defined $self);
fail(__PACKAGE__.'::unpack', __LINE__, 'defined $self->{data}', "there is no data in packet") if !(defined $self->{data});
fail(__PACKAGE__.'::unpack', __LINE__, 'defined $template', "template is not defined") if !(defined $template);
	my @values;
	if (!defined $len) {
		@values = CORE::unpack($template.'a*', substr($self->{data}, $self->{pos}));
		fail(__PACKAGE__.'::unpack', __LINE__, '$#values != -1', "cannot unpack requested data") if $#values == -1;
		$self->{pos} = length($self->{data}) - length(pop(@values));
#		$self->{data} = pop(@values);
	} else {
		my $d = substr($self->{data}, $self->{pos}, $len);
		@values = CORE::unpack($template, $d);
		$self->{pos} += $len;
	}
fail(__PACKAGE__.'::unpack', __LINE__, 'defined $self->{data}', "data container is empty") if !(defined $self->{data});
#print "@values\n";
	return @values;
}
sub pack {
	my $self = shift;
	my $template = shift;
fail(__PACKAGE__.'::pack', __LINE__, 'defined $template', "template is not defined") if !(defined $template);
fail(__PACKAGE__.'::pack', __LINE__, 'defined @_', "data is not defined") if !(defined @_);
fail(__PACKAGE__.'::pack', __LINE__, 'defined $self', "packet is not defined") unless defined $self;
#print "@_\n";
	$self->{data} .= CORE::pack($template, @_);
}
use constant template_for_scalar => {
	h32	=> 'V',
	h16	=> 'v',
	h8	=> 'C',
	u32	=> 'V',
	u16	=> 'v',
	u8	=> 'C',
	s32	=> 'l',
	s16	=> 'v',
	s8	=> 'C',
	sz	=> 'Z*',
	f32	=> 'f',
	guid	=> 'a[16]',
	ha1	=> 'a[12]',
	ha2	=> 'a[8]',
};
use constant template_len => {
	'V' => 4,
	'v' => 2,
	'C' => 1,
	'l' => 4,
	'f' => 4,
	'a[16]' => 16,
	'C8' => 8,
	'C4' => 4,
	'f3' => 12,
	'f4' => 16,
	'l3' => 12,
	'l4' => 16,
	'V3' => 12,
	'V4' => 16,	
	'a[12]'	=> 12,
	'a[8]' => 8,
	'a[171]' => 171,
};
use constant template_for_vector => {
	l8u8v	=> 'C/C',
	l8u16v	=> 'C/V',
	l32u8v	=> 'V/C',
	l32u16v	=> 'V/v',
	l32u32v	=> 'V/V',
	l32szv	=> 'V/(Z*)',
	l8szbv	=> 'C/(Z*C)',
	u8v8	=> 'C8',
	u8v3	=> 'C3',
	u8v4	=> 'C4',
	f32v3	=> 'f3',
	f32v4	=> 'f4',
	s32v3	=> 'l3',
	s32v4	=> 'l4',
	h32v3	=> 'V3',
	h32v4	=> 'V4',	
	actorData => 'C171',
};
sub unpack_properties {
	my $self = shift;
	my $container = shift;
	foreach my $p (@_) {
#print "$p->{name} = ";
		if ($p->{type} eq 'shape') {
			my ($count) = $self->unpack('C', 1);
			while ($count--) {
				my %shape;
				($shape{type}) = $self->unpack('C', 1);
				if ($shape{type} == 0) {
					@{$shape{sphere}} = $self->unpack('f4', 16);
				} elsif ($shape{type} == 1) {
					@{$shape{box}} = $self->unpack('f12', 48);
				} else {
					fail(__PACKAGE__.'::unpack_properties', __LINE__, '$shape{type} == 0 or $shape{type} == 1', "shape has undefined type ($shape{type})");
				}
				push @{$container->{$p->{name}}}, \%shape;
			}
		} elsif ($p->{type} eq 'ordaf') {
			my ($count) = $self->unpack('V', 4);
			while ($count--) {
				my $obj = {};
				($obj->{unknown_string}) = $self->unpack('Z*');
				($obj->{unknown_number}) = $self->unpack('V', 4);
				my ($inner_count) = $self->unpack('V', 4);
				while ($inner_count--) {
					my $afs = {}; 
					($afs->{artefact_name}) = $self->unpack('Z*');
					($afs->{number_1}, 
					$afs->{number_2}) = $self->unpack('VV', 8);
					push @{$obj->{af_sects}}, $afs;
				}
				push @{$container->{$p->{name}}}, $obj;
			}
		} elsif ($p->{type} eq 'supplies') {
			my ($count) = $self->unpack('V', 4);
			while ($count--) {
				my $obj = {};
				($obj->{section_name}) = $self->unpack('Z*');
				($obj->{item_count}, $obj->{min_factor}, $obj->{max_factor}) = $self->unpack('Vff', 12);
				push @{$container->{$p->{name}}}, $obj;
			}
		} elsif ($p->{type} eq 'f32v4') {				#let's shut up #QNAN warnings.
			my @buf = $self->unpack('f4', 16);
			my $i = 0;
			while ($i < 4) {
				if (!defined ($buf[$i] <=> 9**9**9)) {
#					print "replacing bad float $buf[$i]...\n";
					$buf[$i] = 0;
				}
				$i++;
			}
			@{$container->{$p->{name}}} = @buf;
		} elsif ($p->{type} eq 'f32v3') {				
			my @buf = $self->unpack('f3', 12);
			my $i = 0;
			while ($i < 3) {
				if (!defined ($buf[$i] <=> 9**9**9)) {
#					print "replacing bad float $buf[$i]...\n";
					$buf[$i] = 0;
				}
				$i++;
			}
			@{$container->{$p->{name}}} = @buf;
		} elsif ($p->{type} eq 'afspawns' or $p->{type} eq 'afspawns_u32') {
			my ($count) = $self->unpack('v', 2);
			while ($count--) {
				my $obj = {};
				if ($p->{type} eq 'afspawns') {
					($obj->{section_name}) = $self->unpack('Z*');
					($obj->{weight}) = $self->unpack('f', 4);
				} else {
					($obj->{section_name}) = $self->unpack('Z*');
					($obj->{weight}) = $self->unpack('V', 4);
				}
				push @{$container->{$p->{name}}}, $obj;
			}
		} else {
			my $template = template_for_scalar->{$p->{type}};
			if (defined $template) {
				if (CORE::length($self->{data}) == $self->{pos} || (defined template_len->{$template} && $self->resid() < template_len->{$template})) {
					$self->error_handler($container, $template) ;
					return;
				}
				($container->{$p->{name}}) = $self->unpack($template, template_len->{$template});
				if ($p->{type} eq 'sz') {
					chomp $container->{$p->{name}};
					$container->{$p->{name}} =~ s/\r//g;
				}
			} elsif ($p->{type} eq 'u24') {
				($container->{$p->{name}}) = CORE::unpack('V', CORE::pack('CCCC', $self->unpack('C3', 3), 0));
			} elsif ($p->{type} eq 'q16') {
				my ($qf) = $self->unpack('v', 2);
				($container->{$p->{name}}) = convert_q16($qf);
			} elsif ($p->{type} eq 'q16_old') {
				my ($qf) = $self->unpack('v', 2);
				($container->{$p->{name}}) = convert_q16_old($qf);
			} elsif ($p->{type} eq 'q8') {
				my ($q8) = $self->unpack('C', 1);
				($container->{$p->{name}}) = convert_q8($q8);
			} elsif ($p->{type} eq 'q8v3') {
				my (@q8) = $self->unpack('C3', 3);
				my $i = 0;
				while ($i < 3) {
					@{$container->{$p->{name}}}[$i] = convert_q8($q8[$i]);
					$i++;
				}
			} elsif ($p->{type} eq 'q8v4') {
				my (@q8) = $self->unpack('C4', 4);
				my $i = 0;
				while ($i < 4) {
					@{$container->{$p->{name}}}[$i] = convert_q8($q8[$i]);
					$i++;
				}
			} else {
				@{$container->{$p->{name}}} = $self->unpack(template_for_vector->{$p->{type}});
			}
		}
	}
}
sub pack_properties {
	my $self = shift;
	my $container = shift;

	foreach my $p (@_) {
#print "$p->{name} = ";
		my $template = template_for_scalar->{$p->{type}};
		if (defined $template) {
			$self->pack($template, $container->{$p->{name}});
		} elsif ($p->{type} eq 'shape') {
			$self->pack('C', $#{$container->{$p->{name}}} + 1);
			foreach my $shape (@{$container->{$p->{name}}}) {
				$self->pack('C', $$shape{type});
				if ($$shape{type} == 0) {
					$self->pack('f4', @{$$shape{sphere}});
				} elsif ($$shape{type} == 1) {
					$self->pack('f12', @{$$shape{box}});
				}
			}
		} elsif ($p->{type} eq 'u24') {
			$self->pack('CCC', CORE::unpack('CCCC', CORE::pack('V', $container->{$p->{name}})));
		} elsif ($p->{type} eq 'q16') {
			my $f16 = $container->{$p->{name}};
			$self->pack("v", convert_u16($f16));
		} elsif ($p->{type} eq 'q16_old') {
			my $f16 = $container->{$p->{name}};
			$self->pack("v", convert_u16_old($f16));
		} elsif ($p->{type} eq 'supplies') {
			if (@{$container->{$p->{name}}}[0] eq 'none'){
				$self->pack('V', 0);
				next;
			}
			$self->pack('V', $#{$container->{$p->{name}}} + 1);
			foreach my $sect (@{$container->{$p->{name}}}) {
				$self->pack('Z*Vff', $$sect{section_name}, $$sect{item_count}, $$sect{min_factor}, $$sect{max_factor});
			}
		} elsif ($p->{type} eq 'ordaf') {
			if (@{$container->{$p->{name}}}[0] eq 'none'){
				$self->pack('V', 0);
				next;
			}
			$self->pack('V', $#{$container->{$p->{name}}} + 1);
			foreach my $sect (@{$container->{$p->{name}}}) {
				$self->pack('Z*VV', $$sect{unknown_string}, $$sect{unknown_number}, $#{$sect->{af_sects}} + 1);
				foreach my $obj (@{$sect->{af_sects}}) {
					$self->pack('Z*VV', $$obj{artefact_name}, $$obj{number_1}, $$obj{number_2});
				}
			}
		} elsif ($p->{type} eq 'afspawns') {
			if (@{$container->{$p->{name}}}[0] eq 'none'){
				$self->pack('V', 0);
				next;
			}
			$self->pack('v', $#{$container->{$p->{name}}} + 1);
			foreach my $sect (@{$container->{$p->{name}}}) {
				$self->pack('Z*f', $$sect{section_name}, $$sect{weight});
			}
		} elsif ($p->{type} eq 'afspawns_u32') {
			if (@{$container->{$p->{name}}}[0] eq 'none'){
				$self->pack('v', 0);
				next;
			}
			$self->pack('v', $#{$container->{$p->{name}}} + 1);
			foreach my $sect (@{$container->{$p->{name}}}) {
				$self->pack('Z*V', $$sect{section_name}, $$sect{weight});
			}
		} elsif ($p->{type} eq 'q8') {
			my $f8 = $container->{$p->{name}};
			$self->pack("C", convert_u8($f8));
		} else {
			my $n = $#{$container->{$p->{name}}} + 1;
			if ($p->{type} eq 'l32u16v') {
				$self->pack("Vv$n", $n, @{$container->{$p->{name}}});
			} elsif ($p->{type} eq 'l32u8v') {
				$self->pack("VC$n", $n, @{$container->{$p->{name}}});
			} elsif ($p->{type} eq 'l32u32v') {
				$self->pack("VV$n", $n, @{$container->{$p->{name}}});
			} elsif ($p->{type} eq 'l32szv') {
				$self->pack("V(Z*)$n", $n, @{$container->{$p->{name}}});
			} elsif ($p->{type} eq 'l8u8v') {
				$self->pack("CC$n", $n, @{$container->{$p->{name}}});
			} elsif ($p->{type} eq 'l8u16v') {
				$self->pack("CV$n", $n, @{$container->{$p->{name}}});
			} elsif ($p->{type} eq 'q8v') {
				$self->pack("C$n", @{$container->{$p->{name}}});
			} elsif ($p->{type} eq 'q8v3' or $p->{type} eq 'q8v4') {
				foreach my $u8 (@{$container->{$p->{name}}}) {
					$self->pack('C', convert_u8($u8));
				}
			} elsif ($p->{type} eq 'l8szbv') {
				$n = $n/2;
				$self->pack("C(Z*C)$n", $n, @{$container->{$p->{name}}});
			} elsif (exists (template_for_vector->{$p->{type}})) {
				$self->pack(template_for_vector->{$p->{type}}, @{$container->{$p->{name}}});
			} else {
				fail(__PACKAGE__.'::pack_properties', __LINE__, '', "cannot find proper template for type $p->{type}");
			}
		}
	}
}
sub length {return CORE::length($_[0]->{data})}
sub resid {return CORE::length($_[0]->{data}) - $_[0]->{pos}}
sub r_tell {return $_[0]->{init_length} - $_[0]->resid()}
sub w_tell {return CORE::length($_[0]->{data})}
sub data {return $_[0]->{data}}
sub convert_q8 {
	my ($u) = @_;
	my $q = ($u / 255.0);
	return $q;
}
sub convert_u8 {
	my ($q) = @_;
	my $u = int ($q * 255.0);
	return $u;
}
sub convert_q16 {
	my ($u) = @_;
	my $q = (($u / 43.69) - 500.0);
	return $q;
}
sub convert_u16 {
	my ($q) = @_;
	my $u = (($q + 500.0) * 43.69);
	return $u;
}
sub convert_q16_old {
	my ($u) = @_;
	my $q = (($u / 32.77) - 1000.0);
	return $q;
}
sub convert_u16_old {
	my ($q) = @_;
	my $u = (($q + 1000.0) * 32.77);
	return $u;
}
sub error_handler {
	my $self = shift;
	my ($container, $template) = @_;
	print "handling error with $container->{section_name}\n";
	SWITCH: {
		# Nar Sol fix
		($template eq 'C') && (ref($container) eq 'se_zone_anom') && $container->{version} == 118 && $container->{script_version} == 6 && do {
			bless $container, 'cse_alife_anomalous_zone';
			$container->{ini}->{sections_hash}{'sections'}{$container->{section_name}} = 'cse_alife_anomalous_zone';
			last;
		};
		# builds 25xx fix
		(ref($container) =~ /cse_alife_item_weapon_/) && $container->{version} == 118 && $container->{script_version} == 5 && do {
			if (ref($container) eq 'cse_alife_item_weapon_shotgun') {
				bless $container, 'cse_alife_item_weapon_magazined';
			} else {
				bless $container, 'cse_alife_item_weapon';
			}
			fix_25xx($self, $container);
			last;
		};		
		(ref($container) =~ /stalker|monster|actor/) && $container->{version} == 118 && $container->{script_version} == 5 && do {
			fix_25xx($self, $container);
			last;
		};		
		fail(__PACKAGE__.'::error_handler', __LINE__, '', "unhandled exception\n");
	}
}
sub fix_25xx {
	$_[1]->{flags} |= FL_IS_25XX;
	$_[0]->{pos} = 2;
	$_[1]->update_read($_[0]);
	$_[0]->{pos} = 42 if ref($_[1]) =~ /stalker|monster/;
	$_[0]->{pos} = 44 if ref($_[1]) =~ /actor/;
	foreach my $section (keys %{$_[1]->{ini}->{sections_hash}{'sections'}}) {
		if ($_[1]->{ini}->{sections_hash}{'sections'}{$section} =~ /cse_alife_item_weapon_magazined/) {
			$_[1]->{ini}->{sections_hash}{'sections'}{$section} = 'cse_alife_item_weapon';
		} elsif ($_[1]->{ini}->{sections_hash}{'sections'}{$section} eq 'cse_alife_item_weapon_shotgun') {
			$_[1]->{ini}->{sections_hash}{'sections'}{$section} = 'cse_alife_item_weapon_magazined';
		}
	}
}
1;
