#!perl
# ACDC Universal 1.25 (26-12-2011)
#######################################################################
package gg_version;
use strict;
use constant build_versions => (
	{ version => 128, script_version => 12, build => 'Call Of Pripyat (any patch)',  graph_build => 'cop', graph_ver => 10},
	{ version => 124, script_version => 8, build => 'Clear Sky (1.5.04 - 1.5.10)',  graph_build => 'cop', graph_ver => 10},
	{ version => 123, script_version => 8, build => 'Clear Sky (1.5.03)',  graph_build => 'cop', graph_ver => 10},
	{ version => 122, script_version => 8, build => 'Clear Sky (1.5.00 - 1.5.02)',  graph_build => 'cop', graph_ver => 10},
	{ version => 118, script_version => 6, build => 'Shadow Of Chernobyl (1.0001 or higher)',  graph_build => 'soc', graph_ver => 8},
	{ version => 118, script_version => 5, build => 'xrCore build 2559-2947', graph_build => 'soc', graph_ver => 8},
	{ version => 117, script_version => 4, build => 'xrCore build 2571', graph_build => 'soc', graph_ver => 8},
	{ version => 115, script_version => 3, build => 'xrCore build 2365', graph_build => 'soc', graph_ver => 8},
	{ version => 109, script_version => 2, build => 'xrCore build 2307', graph_build => '2215', graph_ver => 8},
	{ version => 104, script_version => 2, build => 'xrCore build 2217, 2232', graph_build => '2215', graph_ver => 8},
	{ version => 103, script_version => 2, build => 'xrCore build 2198, 2191', graph_build => '2215', graph_ver => 8},
	{ version => 102, script_version => 2, build => 'xrCore build 2221', graph_build => '2215', graph_ver => 8},
	{ version => 101, script_version => 2, build => 'xrCore build 2205, 2215', graph_build => '2215', graph_ver => 8},
	{ version => 95, script_version => 1, build => 'xrCore build 2218-2201', graph_build => '1935', graph_ver => 7},
	{ version => 94, script_version => 1, build => 'xrCore build 2212-2217', graph_build => '1935', graph_ver => 7},
	{ version => 93, script_version => 0, build => 'xrCore build 2202', graph_build => '1935', graph_ver => 7},
	{ version => 92, script_version => 0, build => 'xrCore build 1994', graph_build => '1935', graph_ver => 7},
	{ version => 90, script_version => 0, build => 'xrCore build 1964-1971', graph_build => '1935', graph_ver => 7},
	{ version => 89, script_version => 0, build => 'xrCore build 1957', graph_build => '1935', graph_ver => 7},
	{ version => 85, script_version => 0, build => 'xrCore build 1936', graph_build => '1935', graph_ver => 7},
	{ version => 79, script_version => 0, build => 'xrCore build 1935', graph_build => '1935', graph_ver => 7},
	{ version => 77, script_version => 0, build => 'xrCore build 1925', graph_build => '1935', graph_ver => 7},
	{ version => 76, script_version => 0, build => 'xrCore build 1902-1917', graph_build => '1510', graph_ver => 7},
	{ version => 75, script_version => 0, build => 'xrCore build 1893', graph_build => '1510', graph_ver => 7},
	{ version => 73, script_version => 0, build => 'xrCore build 1875', graph_build => '1510', graph_ver => 7},
	{ version => 72, script_version => 0, build => 'xrCore build 1865', graph_build => '1510', graph_ver => 7},
	{ version => 65, script_version => 0, build => 'xrCore build 1850', graph_build => '1510', graph_ver => 7},
	{ version => 63, script_version => 0, build => 'xrCore build 1842', graph_build => '1510', graph_ver => 7},
	{ version => 60, script_version => 0, build => 'xrCore build 1844 (19 May 2005)', graph_build => '1510', graph_ver => 7},
	{ version => 59, script_version => 0, build => 'xrCore build 1833-1835', graph_build => '1510', graph_ver => 7},
	{ version => 56, script_version => 0, build => 'xrCore build 1834 (09 April 2005)', graph_build => '1510', graph_ver => 7},
	{ version => 51, script_version => 0, build => 'xrCore build 1844-1849', graph_build => '1510', graph_ver => 6},
	{ version => 49, script_version => 0, build => 'xrCore build 1835', graph_build => '1510', graph_ver => 5},
	{ version => 47, script_version => 0, build => 'xrCore build 1834 (09 Feb 2005)', graph_build => '1510', graph_ver => 5},
	{ version => 46, script_version => 0, build => 'xrCore build 1829', graph_build => '1510', graph_ver => 5},
	{ version => 45, script_version => 0, build => 'xrCore build 1828', graph_build => '1510', graph_ver => 5},
	{ version => 44, script_version => 0, build => 'xrCore build 1851', graph_build => '1510', graph_ver => 5},
	{ version => 41, script_version => 0, build => 'xrCore build 1837', graph_build => '1510', graph_ver => 5},
	{ version => 40, script_version => 0, build => 'xrCore build 1610-1638', graph_build => '1510', graph_ver => 4},
	{ version => 39, script_version => 0, build => 'xrCore build 1511-1580', graph_build => '1510', graph_ver => 3},
	{ version => 38, script_version => 0, build => 'xrCore build 1510', graph_build => '1510', graph_ver => 3},
	{ version => 35, script_version => 0, build => 'xrCore build 1475', graph_build => '1510', graph_ver => 3},
	{ version => 34, script_version => 0, build => 'xrCore build 1475', graph_build => '1510', graph_ver => 3},
	{ version => 16, script_version => 0, build => 'xrCore build 1472', graph_build => '1472', graph_ver => 3},
	{ version => 14, script_version => 0, build => 'xrCore build 1472', graph_build => '1472', graph_ver => 3},
	{ version => 13, script_version => 0, build => 'xrCore build 1472', graph_build => '1472', graph_ver => 3},
	{ version => 8, script_version => 0, build => 'xrCore build 1469', graph_build => '1469', graph_ver => 3},
	{ version => 7, script_version => 0, build => 'xrCore build 1465', graph_build => '1469', graph_ver => 3},
	{ version => 3, script_version => 0, build => 'xrCore build 1233-1265'},
	{ version => 2, script_version => 0, build => 'xrCore build 1230-1254'},
);
sub graph_ver_by_ver {
	foreach my $info (build_versions) {
		if ($_[0] == $info->{version}) {
			return $info->{graph_ver};
		}
	}
	return undef;	
}
sub scr_ver_by_version {	#returns script_version by version
	foreach my $info (build_versions) {
		if ($_[0] >= $info->{version}) {
			return $info->{script_version};
		}
	}
	return undef;
}
sub build_by_version {		#returns build number by version
	foreach my $info (build_versions) {
		if (($_[0] == $info->{version}) && ($_[1] == $info->{script_version})) {
			return $info->{build};
		}
	}
	return undef;
}
sub version_by_build {		#returns version by build
	foreach my $info (build_versions) {
		if ($_[0] eq $info->{short_build}) {
			return $info->{version}, $info->{script_version}, $info->{build};
		}
	}
	return undef;
}
sub graph_build {			#returns graph build (for graph unpacking) by version and script_version
	foreach my $info (build_versions) {
		if (($_[0] == $info->{version}) && ($_[1] == $info->{script_version})) {
			return $info->{graph_build};
		}
	}
	return undef;
}
#######################################################################
package convert;		#contains harm classes by spawn version for converting
use strict;
use constant harm_classes => (
	{name => 'se_respawn', start => 116, end => 118},
	{name => 'se_smart_cover', start => 122, end => 128},
	{name => 'se_sim_faction', start => 122, end => 128},
);
sub get_harm {
	my @harm;
	foreach my $sect (harm_classes) {
		if ($_[0] < $sect->{start} || $_[0] > $sect->{end}) {
			push @harm, $sect->{name};
		}
	}
	return @harm;
}
#######################################################################
package all_spawn;
use strict;
use IO::File;
use File::Path;
use stkutils::ini_file;
use stkutils::chunked;
use stkutils::graph;
use stkutils::debug 'fail';
use stkutils::entity;
use stkutils::level_game;
use stkutils::level_gct;
use Cwd;
# enum flags
use constant FL_LEVEL_SPAWN => 0x01;
use constant FL_IS_3120 => 0x02;
use constant FL_IS_2942 => 0x04;
use constant FL_IS_25XX => 0x08;
use constant FL_NO_FATAL => 0x10;
# OOP part
sub new {
	my $class = shift;
	my $self = {};
	$self->{spawn_version} = 0;
	$self->{script_version} = 0;
#	$self->{graph} = stkutils::graph->new();
	$self->{config} = {};
	$self->{flags} = 0;
	bless($self, $class);
	return $self;
}
sub DESTROY {
	my $self = shift;
}
sub set_version {$_[0]->{spawn_version} = $_[1]};
sub get_version {return $_[0]->{spawn_version}};
sub set_script_version {$_[0]->{script_version} = $_[1]};
sub get_script_version {return $_[0]->{script_version}};
sub get_config {return $_[0]->{config}};
sub mode {return $_[0]->{config}->{mode}};
sub idx {return $_[0]->{config}->{compile}->{idx_file}};
sub use_graph {
	if (defined $_[0]->{config}->{split}->{use_graph}) {
		return 1;
	}
	return 0;
};
sub way {
	if (defined $_[0]->{config}->{common}->{way}) {
		return 1;
	}
	return 0;
};
sub graph_dir {return $_[0]->{config}->{common}->{graph_dir}};
sub get_src {return $_[0]->{config}->{common}->{src}};
sub get_out {return $_[0]->{config}->{common}->{out}};
sub get_ini {return $_[0]->{config}->{common}->{sections_ini}};
sub set_ini {$_[0]->{config}->{common}->{sections_ini} = $_[1]};
sub get_af {return $_[0]->{config}->{common}->{af}};
sub get_flag {return $_[0]->{flags}};
sub set_flag {$_[0]->{flags} |= $_[1]};
sub is_3120 {
	if ($_[0]->{flags} & FL_IS_3120) {return 1};
	return undef;
}
sub get_new_gvid {return $_[0]->{config}->{parse}->{new_gvid}};
sub get_old_gvid {return $_[0]->{config}->{parse}->{old_gvid}};
# reading
sub read {
	my $self = shift;
	my $cf = stkutils::chunked->new($self->get_src(), 'r') or fail(__PACKAGE__.'::read', __LINE__, '', 'cannot open '.$self->get_src());
	if (!$self->level()) {
		if ($self->get_version() > 79) {
			while (1) {
				my ($index, $size) = $cf->r_chunk_open();
				defined($index) or last;
				if ($index == 0) {
					$self->read_header($cf);
				} elsif ($index == 1) {
					$self->read_alife($cf);
				} elsif ($index == 2) {
					$self->read_af_spawn($cf);
				} elsif ($index == 3) {
					$self->read_way($cf);
				} elsif ($index == 4) {
					$self->read_graph($cf->r_chunk_data());
				} elsif ($index != 5) {
					fail(__PACKAGE__.'::read', __LINE__, '$index <= 4', 'unexpected chunk index '.$index);
				}
				$cf->r_chunk_close();
			}
		} else {
			my $count;
			my ($index, $size) = $cf->r_chunk_open();
			$self->read_header($cf);
			$cf->r_chunk_close();
			$self->read_alife($cf);
			if ($self->get_version() > 16) {
				($count, $size) = $cf->r_chunk_open();
				$self->read_af_spawn($cf);
				$cf->r_chunk_close();	
			}
		}
	} else {
		$self->read_alife($cf);
	}
	$cf->close();
}
sub read_header {
	my $self = shift;
	my ($cf) = @_;
	print "reading header...\n";
	if ($self->get_version() > 94) {
		(	$self->{graph_version},
			$self->{guid},
			$self->{graph_guid},
			$self->{count},
			$self->{level_count},
		) = unpack('Va[16]a[16]VV', ${$cf->r_chunk_data()});
	} else {
		(	$self->{graph_version},
			$self->{count},
			$self->{unknown},
		) = unpack('VVV', ${$cf->r_chunk_data()});	
	}
}
sub read_alife {
	my $self = shift;
	my ($cf) = @_;
	my $i = 0;
	print "reading alife objects...\n";
	if ($self->get_version() > 79 && !$self->level()) {
		while (1) {
			my ($index, $size) = $cf->r_chunk_open();
			defined($index) or last;
			if ($index == 0) {
				$size == 4 or fail(__PACKAGE__.'::read_alife', __LINE__, '$size == 4', 'unexpected alife objects count size');
				my ($alife_count) = unpack('V', ${$cf->r_chunk_data()});
				$alife_count == $self->{count} or fail(__PACKAGE__.'::read_alife', __LINE__, '$alife_count == $self->{count}', 'alife object count mismatch');
			} elsif ($index == 1) {
				while (1) {
					($index, $size) = $cf->r_chunk_open();
					defined($index) or last;
					my $object = stkutils::entity->new();
					$object->{cse_object}->{flags} = $self->get_flag();
					$object->{cse_object}->{ini} =  $self->get_ini();
					$object->read($cf, $self->get_version());
					$self->set_flag($object->{cse_object}->{flags});
					$self->set_ini($object->{cse_object}->{ini});
					push @{$self->{alife_objects}}, $object;
					$cf->r_chunk_close();
				}
			} elsif ($index == 2) {
				$self->{unk_chunk} = $cf->r_chunk_data();
			}
			$cf->r_chunk_close();
		}
	} else {
		while (1) {
			my ($index, $size) = $cf->r_chunk_open();
			defined $index or last;
			$index < $self->{count} or last if defined $self->{count};
			die unless $i == $index;
			my $object = stkutils::entity->new();
			$object->{cse_object}->{flags} = $self->get_flag();
			$object->{cse_object}->{ini} =  $self->get_ini();
			$object->read($cf, $self->get_version());
			$self->set_flag($object->{cse_object}->{flags});
			$self->set_ini($object->{cse_object}->{ini});
			$cf->r_chunk_close();
			$i++;
			if ($self->mode() eq 'split') {
				push (@{$self->{alife_objects}}, $object) if (ref($object->{cse_object}) eq 'cse_alife_graph_point');
			} else {
				push @{$self->{alife_objects}}, $object;
			}
		}
	}
}
sub read_af_spawn {
	my $self = shift;
	my ($cf) = @_;
	print "reading artefact spawn places...\n";
	$self->{af_spawn_data} = $cf->r_chunk_data();
	if ($self->get_af()) {
		my $packet = stkutils::data_packet->new($self->{af_spawn_data});
		my ($obj_count) = $packet->unpack('V', 4);
		while ($obj_count--) {
			my $afsp = {};
			@{$afsp->{position}} = $packet->unpack('f3', 12);
			($afsp->{level_vertex_id}, $afsp->{distance}) = $packet->unpack('Vf', 8);
			push @{$self->{af_spawn_places}}, $afsp;
		}		
	}
}
sub read_way {
	my $self = shift;
	my ($cf) = @_;
	print "reading way objects...\n";
	while (1) {
		my ($index, $size) = $cf->r_chunk_open();
		defined($index) or last;
		if ($index == 0) {
			$size == 4 or fail(__PACKAGE__.'::read_way', __LINE__, '$size == 4', 'unexpected way objects count size');
			my $way_count = unpack('V', ${$cf->r_chunk_data()});
		} elsif ($index == 1) {
			while (1) {
				($index, $size) = $cf->r_chunk_open();
				defined($index) or last;
				my $object = stkutils::level_game->new();
				$object->read($cf);
				push @{$self->{way_objects}}, $object;
				$cf->r_chunk_close();
			}
		} else {
			fail(__PACKAGE__.'::read_way', __LINE__, '$index <= 1', 'unexpected chunk index '.$index);
		}
		$cf->r_chunk_close();
	}
}
sub read_graph {
	my $self = shift;
	my ($data_ref) = @_;
	$self->{graph_data} = $data_ref;
	$self->set_flag(FL_IS_3120) if $self->get_version() == 118;
	$self->{graph} = stkutils::graph->new($self->{graph_data});
	$self->{graph}->{gg_version} = $self->check_graph_build();
	$self->{graph}->decompose();
	$self->{graph}->read_vertices();
	$self->{graph}->show_guids('guids.ltx');
}
# writing
sub write {
	my $self = shift;
	$self->set_version((@{$self->{alife_objects}}[0])->{cse_object}->{version});
	$self->set_script_version((@{$self->{alife_objects}}[0])->{cse_object}->{script_version});
	$self->{graph_version} = $self->check_graph_version();
	my $cf = stkutils::chunked->new($self->get_out(), 'w') or fail(__PACKAGE__.'::write', __LINE__, '', 'cannot open '.$self->get_out());
	if (!$self->level()) {
		$self->write_header($cf);
		$self->write_alife($cf);
		$self->write_af_spawn($cf);
		$self->write_way($cf);
		$self->write_graph($cf);
		$self->write_service_chunk($cf);
	} else {
		$self->write_alife($cf);
	}
	$cf->close();
}
sub write_header {
	my $self = shift;
	my ($cf) = @_;
	print "writing header...\n";
	if ($self->get_version() > 94) {
		my $data = pack('Va[16]a[16]VV',
			$self->{graph_version},
			$self->{guid},
			$self->{graph_guid},
			$#{$self->{alife_objects}} + 1,
			$self->{level_count});
		$cf->w_chunk(0, $data);
	} else {
		my $data = pack('VVV',
			$self->{graph_version},
			$#{$self->{alife_objects}} + 1,
			$self->{unknown},);
		if ($self->get_version() > 79) {
			$cf->w_chunk(0, $data);	
		} else {
			$cf->w_chunk(0xFFFF, $data);	
		}
	}
}
sub write_alife {
	my $self = shift;
	my ($cf) = @_;
	print "writing alife objects...\n";
	if ($self->get_version() > 79 && !$self->level()) {
		$cf->w_chunk_open(1);
		$cf->w_chunk(0, pack('V', $#{$self->{alife_objects}} + 1));
		$cf->w_chunk_open(1);
		my $id = 0;
		my $file = $self->idx();
		$file = 'spawn_ids' if (defined $file && $file eq '');
		$file .= '.ltx' if (defined $file and (substr($file, -3) ne 'ltx'));
		my $log = IO::File->new($file, 'w') if defined $self->idx();
		my $guids_file = stkutils::ini_file->new('guids.ltx', 'r') or fail(__PACKAGE__.'::write_alife', __LINE__, '', 'cannot open guids.ltx') if defined $self->idx();
		foreach my $object (@{$self->{alife_objects}}) {
			next unless defined $object;
			if ($object->{cse_object}->{section_name} eq "inventory_box") {
				$object->{cse_object}->{object_flags} = 0xffffff3b;
			}
			my $class_name = ref $object->{cse_object};
			$cf->w_chunk_open($id);
			if (defined $self->idx()) {
				my $level_id = get_level_id($guids_file, $object->{cse_object}->{game_vertex_id});
				print $log "\n[".$level_id."_".$object->{cse_object}->{name}."]\n";
				print $log "id = $id\n";
				print $log "story_id = $object->{cse_object}->{story_id}\n";
			}
			$object->write($cf, $id++);
			$cf->w_chunk_close();
		}
		$log->close() if defined $self->idx();
		$guids_file->close() if defined $self->idx();
		$cf->w_chunk_close();
		my $chunk_2 = '';
		$chunk_2 = ${$self->{unk_chunk}} if $self->get_version() == 85;
		$cf->w_chunk(2, $chunk_2);
		$cf->w_chunk_close();
	} else {
		my $id = 0;
		foreach my $object (@{$self->{alife_objects}}) {
			$cf->w_chunk_open($id);
			$object->write($cf, $id++);
			$cf->w_chunk_close();
		}	
	}
}
sub write_af_spawn {
	my $self = shift;
	my ($cf) = @_;
	if ($self->get_af()) {
		my $data = '';
		foreach my $afsp (@{$self->{af_spawn_places}}) {
			$data .= pack('f3Vf', @{$afsp->{position}}, $afsp->{level_vertex_id}, $afsp->{distance})
		}
		$self->{af_spawn_data} = \$data;
	}
	if (defined $self->{af_spawn_data}){
		print "writing artefact spawn places...\n";
		if ($self->get_version() > 79) {
			$cf->w_chunk(2, ${$self->{af_spawn_data}});
		} else {
			$cf->w_chunk($#{$self->{alife_objects}} + 1, ${$self->{af_spawn_data}});
		}
	}
}
sub write_way {
	my $self = shift;
	my ($cf) = @_;
	if (defined @{$self->{way_objects}}) {
		print "writing way objects...\n";
		$cf->w_chunk_open(3);
		$cf->w_chunk(0, pack('V', $#{$self->{way_objects}} + 1));
		$cf->w_chunk_open(1);
		my $id = 0;
		foreach my $object (@{$self->{way_objects}}) {
			$cf->w_chunk_open($id++);
			$object->write($cf);
			$cf->w_chunk_close();
		}
		$cf->w_chunk_close();
		$cf->w_chunk_close();
	}
}
sub write_graph {
	my $self = shift;
	my ($cf) = @_;
	my $new_graph_ver = $self->check_graph_build();
	print "writing graph...\n";
	if (!defined $self->{graph}->{gg_version} || $self->{graph}->{gg_version} eq $new_graph_ver) {
		# -compile
		return if $new_graph_ver ne 'cop';
		$cf->w_chunk(4, ${$self->{graph_data}});
	} elsif ($self->{graph}->{gg_version} eq 'cop') {
		# convert from cs/cop spawn, so we need to split graph
		# write cross tables
		File::Path::mkpath('levels', 0);
		my $wd = getcwd();
		chdir 'levels' or fail(__PACKAGE__.'::write_graph', __LINE__, '', 'cannot change path to levels');
		foreach my $level (values %{$self->{graph}->{level_by_guid}}) {
			File::Path::mkpath($level, 0);
			my $ctfh = IO::File->new($level.'/level.gct', 'w') or fail(__PACKAGE__.'::write_graph', __LINE__, '', 'cannot open '.$level.'/level.gct');
			my $ct = stkutils::level_gct->new($self->{graph}->{raw_cross_tables}{$level});
			$ct->read();
			$ct->set_version($self->check_graph_version());
			$ct->write();
			my $data = $ct->get_data();
			$ctfh->write($$data, length($$data));
			$ctfh->close();
		}
		chdir $wd or fail(__PACKAGE__.'::write_graph', __LINE__, '', 'cannot change path to '.$wd);
		$self->{graph}->{gg_version} = $new_graph_ver;
		my $graph_data = $self->{graph}->compose();
		# write graph
		my $fh = IO::File->new('game.graph', 'w');
		binmode $fh;
		$fh->write($$graph_data, length($$graph_data));
		$fh->close();
	} elsif ($new_graph_ver eq 'cop') {
		# convert to cs/cop spawn, so we need to form graph
		# read cross tables
		foreach my $level (values %{$self->{graph}->{level_by_guid}}) {
			my $ctfh = IO::File->new('levels/'.$level.'/level.gct', 'r') or fail(__PACKAGE__.'::write_graph', __LINE__, '', 'cannot open levels/'.$level.'/level.gct');
			binmode $ctfh;
			my $data = '';
			$ctfh->read($data, ($ctfh->stat())[7]);
			$ctfh->close();
			my $ct = stkutils::level_gct->new(\$data);
			$ct->read();
			$ct->set_version($self->check_graph_version());
			$ct->write();
			$self->{graph}->{raw_cross_tables}{$level} = $ct->get_data();
		}		
		$self->{graph}->{gg_version} = 'cop';
		my $graph_data = $self->{graph}->compose();
		# write graph
		$cf->w_chunk(4, $$graph_data);
	}
}
# importing
sub import {
	my $self = shift;
	if (!$self->level()) {
		 my $if = stkutils::ini_file->new('all.ltx', 'r') or fail(__PACKAGE__.'::import', __LINE__, '', 'cannot open all.ltx');
		$self->import_header($if);
		$self->import_alife($if);
		$self->set_version((@{$self->{alife_objects}}[0])->{cse_object}->{version});
		$self->import_af_spawn($if);
		$self->import_way($if);
		$self->import_graph($if);
		$if->close();
	} else {
		$self->import_level('level_spawn.ltx');
	}
}
sub import_header {
	my $self = shift;
	my ($if) = @_;

	$self->{graph_version} = $if->value('header', 'graph_version');
	$self->{guid} = pack 'H*', $if->value('header', 'guid') if defined $if->value('header', 'guid');
	$self->{graph_guid} = pack 'H*', $if->value('header', 'graph_guid') if defined $if->value('header', 'graph_guid');
	$self->{level_count} = $if->value('header', 'level_count');
	$self->{unknown} = $if->value('header', 'unknown');
	$self->{flags} = $if->value('header', 'flags') if defined $if->value('header', 'flags');
}
sub import_alife {
	my $self = shift;
	my ($if) = @_;
	unlink 'spawn_ids.log' if -e 'spawn_ids.log';
	my $id = 0;
	my $idx_log = IO::File->new('spawn_ids.log', 'w') if !defined $self->idx();
	foreach my $fn (split /,/, ($if->value('alife', 'source_files') or fail(__PACKAGE__.'::import_alife', __LINE__, '$if->value(alife, source_files)', 'cannot find any locations in all.ltx'))) {
		$fn =~ s/^\s*|\s*$//g;
		my $lif;
		if ($fn eq 'alife_$debug$\y_selo.ltx') {
			$lif = stkutils::ini_file->new('alife_debug_y_selo.ltx', 'r') or fail(__PACKAGE__.'::import_alife', __LINE__, '', 'cannot open alife_debug_y_selo.ltx');
		} else {
			$lif = stkutils::ini_file->new($fn, 'r') or fail(__PACKAGE__.'::import_alife', __LINE__, '', 'cannot open '.$fn);
		}
		print "importing alife objects from file $fn...\n";
		foreach my $section (@{$lif->{sections_list}}) {
			my $object = stkutils::entity->new();
			$object->{cse_object}->{flags} |= $self->get_flag();
			$object->import_ltx($lif, $section, $self->get_ini());
			if (defined $object->{cse_object}->{custom_data} && $object->{cse_object}->{custom_data} =~ /^(.*)\[(spawn_id)\]/s) {
				$object->{cse_object}->{custom_data} = $1."[spawn_id]\n$object->{cse_object}->{name} = $id";
				print $idx_log "\n[$object->{cse_object}->{name}]\nnew_idx = $id\n" if !defined $self->idx();
			}
			push @{$self->{alife_objects}}, $object;
			$id++;
		}
		$lif->close();
	}
	if ($if->is_value_exists('unk', 'binary_files')) {
		my $fn = $if->value('unk', 'binary_files');
		my $bin_fh = IO::File->new($fn, 'r') or fail(__PACKAGE__.'::import_alife', __LINE__, '', 'cannot open '.$fn);
		binmode $bin_fh;
		my $data = '';
		$bin_fh->read($data, ($bin_fh->stat())[7]);
		$self->{unk_chunk} = \$data;
		$bin_fh->close();	
	}
	$idx_log->close() if !defined $self->idx();
}
sub import_level {
	my $self = shift;
	my ($if) = @_;
	my ($lif) = stkutils::ini_file->new($if, 'r') or fail(__PACKAGE__.'::import_level', __LINE__, '', 'cannot open '.$if);
	print "importing alife objects from $if\n";
	foreach my $section (@{$lif->{sections_list}}) {
		my $object = stkutils::entity->new();
		$object->{cse_object}->{flags} = $self->get_flag();
		$object->import_ltx($lif, $section, $self->get_ini());
		push @{$self->{alife_objects}}, $object;
	}
	$lif->close();
}
sub import_af_spawn {
	my $self = shift;
	my ($if) = @_;
	if ($self->get_af()) {
		my $fh = stkutils::ini_file->new('af_spawn_places.ltx', 'r') or fail(__PACKAGE__.'::import_af_spawn', __LINE__, '', 'cannot open af_spawn_places.ltx');
		foreach my $id (@{$fh->{sections_list}}) {
			my $afsp = {};
			@{$afsp->{position}} = split /,\s*/, $fh->value($id, 'position');
			$afsp->{level_vertex_id} = $fh->value($id, 'level_vertex_id');
			$afsp->{distance} = $fh->value($id, 'distance');
			push @{$self->{af_spawn_places}}, $afsp;
		}
		$fh->close();		
	} else {
		return if !defined $if->value('section2', 'binary_files');
		my $fn = $if->value('section2', 'binary_files');
		my $bin_fh = IO::File->new($fn, 'r') or fail(__PACKAGE__.'::import_af_spawn', __LINE__, '', 'cannot open '.$fn);
		binmode $bin_fh;
		print "importing artefact spawn places data...\n";
		my $data = '';
		$bin_fh->read($data, ($bin_fh->stat())[7]);
		$self->{af_spawn_data} = \$data;
	}
}
sub import_way {
	my $self = shift;
	my ($if) = @_;
	my $fn = $if->is_section_exists('way') or return;
	foreach my $fn (split /,/, ($if->value('way', 'source_files') or return)) {
		$fn =~ s/^\s*|\s*$//g;
		my $lif;
		if ($fn eq 'way_$debug$\y_selo.ltx') {
			$lif = stkutils::ini_file->new('way_debug_y_selo.ltx', 'r') or stkutils::debug::fail(__PACKAGE__.'::import_way', __LINE__, '', 'cannot open way_debug_y_selo.ltx');
		} else {
			$lif = stkutils::ini_file->new($fn, 'r') or stkutils::debug::fail(__PACKAGE__.'::import_way', __LINE__, '', 'cannot open '.$fn);
		}
		print "importing way objects from file $fn...\n";
		foreach my $section (@{$lif->{sections_list}}) {
			my $object = stkutils::level_game->new();
			$object->importing($lif, $section);
			push @{$self->{way_objects}}, $object;
		}
		$lif->close();
	}
}
sub import_graph {
	my $self = shift;
	my ($if) = @_;
	return if !$if->is_value_exists('graph', 'binary_files');
	print "importing graph...\n";
	my $fn = $if->value('graph', 'binary_files');
	my $bin_fh = IO::File->new($fn, 'r') or fail(__PACKAGE__.'::import_graph', __LINE__, '', 'cannot open '.$fn);
	binmode $bin_fh;
	my $data = '';
	$bin_fh->read($data, ($bin_fh->stat())[7]);
	$bin_fh->close();
	$self->{graph_data} = \$data;
	$self->set_flag(FL_IS_3120) if $self->get_version() == 118;
}
# exporting
sub export {
	my $self = shift;
	my ($fn) = @_;
	if (!$self->level()) {
		my $if = stkutils::ini_file->new($fn, 'w') or fail(__PACKAGE__.'::export', __LINE__, '', 'cannot open '.$fn);
		$self->export_header($if);
		$self->export_alife($if);
		$self->export_af_spawn($if);
		$self->export_way($if);
		$self->export_graph($if) if ($self->get_version() > 118 || $self->is_3120());
		$if->close();
	} else {
		$self->export_level('level_spawn.ltx');
	}		
}
sub export_header {
	my $self = shift;
	my ($if) = @_;

	my $fh = $if->{fh};
	print $fh "[header]\n; don't touch these\n";
	print $fh "graph_version = $self->{graph_version}\n";
	print $fh 'guid = ', unpack('H*', $self->{guid}), "\n" if (defined $self->{guid});
	print $fh 'graph_guid = ', unpack('H*', $self->{graph_guid}), "\n" if (defined $self->{graph_guid});
	print $fh "level_count = $self->{level_count}\n" if (defined $self->{level_count});
	print $fh "unknown = $self->{unknown}\n" if (defined $self->{unknown});
	print $fh "flags = $self->{flags}\n" if $self->{flags} != 0;
	print $fh "\n";
}
sub export_alife {
	my $self = shift;
	my ($if) = @_;

	my $id = 0;
	my %if_by_level;
	my @levels;
	foreach my $object (@{$self->{alife_objects}}) {
		my $cse_object = $object->{cse_object};
		my $level = $self->{graph}->level_name($cse_object->{game_vertex_id});
		fail(__PACKAGE__.'::export_alife', __LINE__, 'defined $level', 'unknown location of the alife object '.$cse_object->{name}) unless defined $level; 
		my $lif = $if_by_level{$level};
		if (!defined $lif) {
			if ($level eq '$debug$\y_selo') {
				$lif = stkutils::ini_file->new("alife_debug_y_selo.ltx", 'w') or fail(__PACKAGE__.'::export_alife', __LINE__, '', 'cannot open alife_alife_debug_y_selo.ltx');
			} else {
				$lif = stkutils::ini_file->new("alife_$level.ltx", 'w') or fail(__PACKAGE__.'::export_alife', __LINE__, '', 'cannot open alife_'.$level.'.ltx');
			}
			print "exporting alife objects on level $level...\n";
			$if_by_level{$level} = $lif;
			push @levels, "alife_$level.ltx";
		}
		$object->export_ltx($lif, $id++);
	}
	if ($self->get_version() == 85) {
		my $bin_fh = IO::File->new('unk_chunk.bin', 'w') or fail(__PACKAGE__.'::export_alife', __LINE__, '', 'cannot open unk_chunk.bin');
		binmode $bin_fh;
		$bin_fh->write(${$self->{unk_chunk}}, length(${$self->{unk_chunk}}));
		$bin_fh->close();
	}
	my $fh = $if->{fh};
	print $fh "[alife]\nsource_files = <<END\n", join(",\n", @levels), "\nEND\n\n";
	print $fh "[unk]\nbinary_files = unk_chunk.bin\n\n" if $self->get_version() == 85;
	foreach $if (values %if_by_level) {
		$if->close();
	}
}
sub export_level {
	my $self = shift;
	my ($if) = @_;

	my $id = 0;
	my $lif = stkutils::ini_file->new($if, 'w') or fail(__PACKAGE__.'::export_level', __LINE__, '', 'cannot open '.$if);
	foreach my $object (@{$self->{alife_objects}}) {
		next unless defined $object;
		$object->export_ltx($lif, $id++);
	}
	$lif->close();
}
sub export_af_spawn {
	my $self = shift;
	my ($if) = @_;
	if ($self->get_af()) {
		my $fh = IO::File->new('af_spawn_places.ltx', 'w') or fail(__PACKAGE__.'::export_af_spawn', __LINE__, '', 'cannot open af_spawn_places.ltx');
		my $id = 0;
		foreach my $afsp (@{$self->{af_spawn_places}}) {
			print $fh "[$id]\n";
			printf $fh "position = %f,%f,%f\n", @{$afsp->{position}}[0..2];
			print $fh "level_vertex_id = $afsp->{level_vertex_id}\n";
			print $fh "distance = $afsp->{distance}\n";
			$id++;
		}
		$fh->close();
	} else {
		my $bin_fh = IO::File->new('section2.bin', 'w') or fail(__PACKAGE__.'::export_af_spawn', __LINE__, '', 'cannot open section2.bin');
		binmode $bin_fh;
		print "exporting raw data...\n";
		$bin_fh->write(${$self->{af_spawn_data}}, length(${$self->{af_spawn_data}}));
		my $fh = $if->{fh};
		print $fh "[section2]\nbinary_files = section2.bin\n\n";
	}
}
use constant way_name_exceptions => {
	kat_teleport_to_dark_city_orientation	=> 'l03u_agr_underground',
	walk_3					=> 'l05_bar',
	rad_heli_move				=> 'l10_radar',
	pri_heli4_go2_path			=> 'l11_pripyat',
	sar_teleport_0000_exit_look		=> 'l12u_sarcofag',
	sar_teleport_0000_exit_walk		=> 'l12u_sarcofag',
	val_ambush_dest_look		=> 'l04_darkvalley',
};
sub export_way {
	my $self = shift;
	my ($if) = @_;
	
	if (defined @{$self->{way_objects}}) {
		my %info_by_level;

		my $default_level = 'l05_bar';
		foreach my $object (@{$self->{way_objects}}) {
			my $level = $self->{graph}->level_name($object->{points}[0]->{game_vertex_id});
			if (defined $level) {
				$default_level = $level;
			} else {
				# either get the name from the exceptions table
				# or use the current default (i.e. previous) value
				$level = (way_name_exceptions->{$object->{name}} or $default_level);
			}
			fail(__PACKAGE__.'::export_way', __LINE__, 'defined $level', 'unknown level of the way object '.$object->{name}) unless defined $level;
			my $info = $info_by_level{$level};
			if (!defined $info) {
				$info = {};
				if ($level eq '$debug$\y_selo') {
					$info->{lif} = stkutils::ini_file->new("way_debug_y_selo.ltx", 'w') or fail(__PACKAGE__.'::export_way', __LINE__, '', 'cannot open way_debug_y_selo.ltx');
				} else {
					$info->{lif} = stkutils::ini_file->new("way_$level.ltx", 'w') or fail(__PACKAGE__.'::export_way', __LINE__, '', 'cannot open way_'.$level.'.ltx');
				}
				$info->{way_objects} = ();
				$info_by_level{$level} = $info;
			}
			push @{$info->{way_objects}}, $object;
		}

		my $id = 0;
#		foreach my $info (values %info_by_level) {
		while (my ($level, $info) = each %info_by_level) {
			print "exporting way objects on level $level...\n";
#			foreach my $object (sort {$a->{name} cmp $b->{name}}  @{$info->{way_objects}}) {
			foreach my $object (@{$info->{way_objects}}) {
				$object->export($info->{lif}, $id++);
			}
			$info->{lif}->close();
		}
		my $fh = $if->{fh};
		print $fh "[way]\nsource_files = <<END\n", join(",\n", map {"way_$_.ltx"} (keys %info_by_level)), "\nEND\n\n";
	}
}
sub export_graph {
	my $self = shift;
	my ($if) = @_;
	print "exporting graph...\n";
	my $fn = 'section4.bin';
	my $bin_fh = IO::File->new($fn, 'w') or fail(__PACKAGE__.'::export_graph', __LINE__, '', 'cannot open '.$fn);
	binmode $bin_fh;
	$bin_fh->write(${$self->{graph_data}}, length(${$self->{graph_data}}));
	$bin_fh->close();
	my $fh = $if->{fh};
	print $fh "[graph]\nbinary_files = $fn\n\n";
}
# split spawns
sub prepare_graph_points {
	my $self = shift;
	my $graph = $self->{graph};
	print "preparing graph points...\n";
	my $i = 0;
	foreach my $vertex (@{$graph->{vertices}}) {
		$vertex->{name} = $graph->{level_by_id}{$vertex->{level_id}}->{level_name}.'_graph_point_'.$i;
		$vertex->{id} = $i;
		$i++;
	}
	foreach my $object (@{$self->{alife_objects}}) {
		next if (ref($object->{cse_object}) ne 'se_level_changer');
		@{$graph->{vertices}}[$object->{cse_object}->{dest_game_vertex_id}]->{name} = $object->{cse_object}->{dest_graph_point};
	}
	foreach my $level (values %{$graph->{level_by_guid}}) {
		my $level_spawn = all_spawn->new();
		$level_spawn->{level_name} = $level;
		$level_spawn->{config}->{common}->{src} = ''; 
		$level_spawn->{config}->{common}->{out} = $level.'/level.spawn';
		$level_spawn->set_flag(FL_LEVEL_SPAWN);
		my $id = 0;
		foreach my $vertex (@{$graph->{vertices}}) {
			if ($graph->{level_by_id}{$vertex->{level_id}}->{level_name} eq $level) {
				my $object = stkutils::entity->new();
				$self->convert_point($object, $vertex, $level, $id++);
				push @{$level_spawn->{alife_objects}}, $object;
			}
		}
		$self->split_spawns($level_spawn);
		push @{$self->{level_spawns}}, $level_spawn;
	}
}
sub convert_point {
	my $self = shift;
	my ($object, $vertex, $level, $id) = @_;
	my $graph = $self->{graph};
#	print "	converting vertices of level $level...\n";
	$object->init_abstract();
	$object->{cse_object}->{version} = $self->get_version();
	$object->{cse_object}->{script_version} = $self->get_script_version();
	bless $object->{cse_object}, 'cse_alife_graph_point';
	$object->init_object();
	$object->{cse_object}->{name} = $vertex->{name};
	$object->{cse_object}->{section_name} = 'graph_point';
	$object->{cse_object}->{position} = $vertex->{level_point};
	$object->{cse_object}->{direction} = [0,0,0];
	for (my $i = 0; $i < $vertex->{edge_count}; $i++) {
		my $edge = @{$graph->{edges}}[$vertex->{edge_index} + $i];
		my $vertex2 = @{$graph->{vertices}}[$edge->{game_vertex_id}];
		if ($vertex->{level_id} != $vertex2->{level_id}) {
			my $level2 = $graph->{level_by_id}{$vertex2->{level_id}};
			my $name2 = $level2->{level_name};
			$object->{cse_object}->{connection_point_name} = $vertex2->{name};
			$object->{cse_object}->{connection_level_name} = $name2;
		}
	}
	$object->{cse_object}->{location0} = $vertex->{vertex_type}[0];
	$object->{cse_object}->{location1} = $vertex->{vertex_type}[1];
	$object->{cse_object}->{location2} = $vertex->{vertex_type}[2];
	$object->{cse_object}->{location3} = $vertex->{vertex_type}[3];
}
sub read_level_spawns {
	my $self = shift;
	print "splitting spawns...\n";
	# prepare arrays with level spawns
	foreach my $level (values %{$self->{graph}->{level_by_guid}}) {
		my $level_spawn = all_spawn->new();
		$level_spawn->{level_name} = $level;
		$level_spawn->{config}->{common}->{src} = $level_spawn->{config}->{common}->{out} = $level.'/level.spawn';
		$level_spawn->{config}->{common}->{level_spawn} = 1;
		$level_spawn->{config}->{mode} = 'split';
		$level_spawn->read();	
		$self->split_spawns($level_spawn);
		push @{$self->{level_spawns}}, $level_spawn;
	}
}
sub split_spawns {
	my $self = shift;
	my ($ls) = @_;
	print "filling level.spawn with objects ($ls->{level_name})...\n";
	# prepare arrays with level spawns
	foreach my $object (@{$self->{alife_objects}}) {
		if ($self->{graph}->level_name($object->{cse_object}->{game_vertex_id}) eq $ls->{level_name}) {
			$object->{cse_object}->{game_vertex_id} = 0xFFFF;
			$object->{cse_object}->{level_vertex_id} = 0xFFFFFFFF;
			$object->{cse_object}->{distance} = 0;
			push @{$ls->{alife_objects}}, $object;
		}
	}
}
sub write_splitted_spawns {
	my $self = shift;
	print "writing level spawns...\n";
	
	foreach my $level_spawn (@{$self->{level_spawns}}) {
		my $level = $level_spawn->{level_name};
		rename $level.'/level.spawn', $level.'/level.spawn.bak' or (unlink $level.'/level.spawn.bak' and rename $level.'/level.spawn', $level.'/level.spawn.bak');
		$level_spawn->write();
	}
}
sub split_ways {
	my $self = shift;
	my $graph = $self->{graph};
	print "splitting ways...\n";
	my %info_by_level;
	foreach my $object (@{$self->{way_objects}}) {
		my $level = $graph->level_name($object->{points}[0]->{game_vertex_id});
		if (!defined $level) {
			$level = (way_name_exceptions->{$object->{name}});
		}
		fail(__PACKAGE__.'::split_ways', __LINE__, 'defined $level', "unknown level of the way object $object->{name}\n") unless defined $level;
		my $info = $info_by_level{$level};
		if (!defined $info) {
			$info = {};
			rename $level.'/level.game', $level.'/level.game.bak' or (unlink $level.'/level.game.bak' and rename $level.'/level.game', $level.'/level.game.bak') ;
			$info->{lif} = stkutils::chunked->new($level.'/level.game', 'w') or fail(__PACKAGE__.'::split_ways', __LINE__, '', "$! $level".'/level.game'."\n");
			$info->{way_objects} = ();
			$info_by_level{$level} = $info;
		}
		push @{$info->{way_objects}}, \$object;
	}
	
	foreach my $info (values %info_by_level) {
		my $id = 0;
		$info->{lif}->w_chunk_open(4096);
		foreach my $object (sort {$$a->{name} cmp $$b->{name}}  @{$info->{way_objects}}) {
			$$object->split_ways($info->{lif}, $id++);
		}
		$info->{lif}->w_chunk_close();
		$info->{lif}->w_chunk_open(8192);
		$info->{lif}->w_chunk_close();
		$info->{lif}->close();
	}
	
}
# convert
sub prepare_objects {
	my $self = shift;
	my $ini_file = $self->{config}->{convert}->{ini};
	$ini_file = 'convert.ini' if !defined $ini_file;
	my $conv_ini = stkutils::ini_file->new($ini_file, 'r') or fail(__PACKAGE__.'::prepare_objects', __LINE__, '', "cannot open $ini_file");
	my @exclude_sects = split /,\s*/, $conv_ini->value('exclude', 'sections') if defined $conv_ini->value('exclude', 'sections');
	my @exclude_classes = convert::get_harm($self->{config}->{convert}->{new_version});
	my %sExclude_simple;
	my %sExclude_regexp;
	foreach my $sect (@exclude_sects) {
		if ($sect !~ /\*/) {
			$sExclude_simple{$sect} = 1;
		} else {
			if ($sect =~ /\*$|^\*/) {
				$sect =~ s/\*//;
				$sExclude_regexp{$sect} = 1;
			} else {
				my @sect = split /\*/, $sect;
				$sExclude_regexp{\@sect} = 1;
			}
		}
	}
	my %clExclude;
	foreach my $class (@exclude_classes) {
		$clExclude{$class} = 1;
	}
	my $id = 0;
	foreach my $object (@{$self->{alife_objects}}) {
		(push (@{$self->{harm_objects}}, $object) and delete($self->{alife_objects}[$id]) and next) if defined $clExclude{ref($object->{cse_object})};
		(push (@{$self->{excluded_objects}}, $object) and delete($self->{alife_objects}[$id]) and next) if defined $sExclude_simple{$object->{cse_object}->{section_name}};
		foreach my $section (keys %sExclude_regexp) {
			if (ref($section) eq 'REF') {
				my $c = 0;
				foreach (@$section) {
					++$c if $object->{cse_object}->{section_name} =~ /$_/;
				}
				(push (@{$self->{excluded_objects}}, $object) and delete($self->{alife_objects}[$id]) and last) if $c == $#{$section} + 1;
			} else {
				(push (@{$self->{excluded_objects}}, $object) and delete($self->{alife_objects}[$id]) and last) if $object->{cse_object}->{section_name} =~ /$section/;
			}
		}
		next if !defined $self->{alife_objects}[$id];
		my %add;
		my %rep;
		if (defined $conv_ini->{sections_hash}{$object->{cse_object}->{section_name}}) {
			foreach my $param (keys %{$conv_ini->{sections_hash}{$object->{cse_object}->{section_name}}}) {
				my @temp = split /:\s*/, $param;
				$add{$temp[1]} = $conv_ini->{sections_hash}{$object->{cse_object}->{section_name}}{$param} if $temp[0] eq 'add';
				$rep{$temp[1]} = $conv_ini->{sections_hash}{$object->{cse_object}->{section_name}}{$param} if $temp[0] eq 'rep';
			}
			foreach my $param (keys %{$object->{cse_object}}) {
				if (defined $add{$param}) {
					if ($add{$param} =~ /^\d+$/) {
						$object->{cse_object}->{$param} += $add{$param};
					} else {
						$object->{cse_object}->{$param} .= $add{$param};
					}
				}
				if (defined $rep{$param}) {
					$object->{cse_object}->{$param} = $rep{$param};
				}
			}
		}
	}
	continue {
		$id++;
	}
	$conv_ini->close();
}
sub print_harm_objects {
	my $self = shift;
	my ($lif) = stkutils::ini_file->new('harm_objects.ltx', 'w') or fail(__PACKAGE__.'::import_level', __LINE__, '', 'cannot open harm_objects.ltx');
	print "exporting harm objects\n";
	my $id = 0;
	foreach my $object (@{$self->{harm_objects}}) {
		$object->export_ltx($lif, $id++);
	}
	$lif->close();	
}
sub print_excluded_objects {
	my $self = shift;
	my ($lif) = stkutils::ini_file->new('excluded_objects.ltx', 'w') or fail(__PACKAGE__.'::import_level', __LINE__, '', 'cannot open excluded_objects.ltx');
	print "exporting excluded objects\n";
	my $id = 0;
	foreach my $object (@{$self->{excluded_objects}}) {
		$object->export_ltx($lif, $id++);
	}
	$lif->close();	
}
# parse
sub parse_way {
	my $self = shift;
	my ($out) = @_;
	# import
	my $fn = $self->get_src();
	$fn =~ s/alife/way/;
	$fn = '../'.$fn;
	my $fh = stkutils::ini_file->new($fn, 'r') or fail(__PACKAGE__.'::parse_way', __LINE__, '', 'cannot open '.$fn);
	print "importing way objects from file $fn...\n";
	foreach my $section (@{$fh->{sections_list}}) {
		my $object = stkutils::level_game->new();
		$object->importing($fh, $section);
		foreach my $point (@{$object->{points}}) {
			$point->{game_vertex_id} += ($self->get_new_gvid() - $self->get_old_gvid());
		}
		push @{$self->{way_objects}}, $object;
	}
	$fh->close();
	# export
	$out =~ s/alife/way/;
	$fh = stkutils::ini_file->new($out, 'w') or fail(__PACKAGE__.'::parse_way', __LINE__, '', 'cannot open '.$out);
	print "exporting way objects to file $out...\n";
	my $id = 0;
	foreach my $object (sort {$a->{name} cmp $b->{name}}  @{$self->{way_objects}}) {
		$object->export($fh, $id++);
	}
	$fh->close();
}
# other subs
sub check_graph_build {
	return 'cop' if $_[0]->is_3120();
	return gg_version::graph_build($_[0]->get_version(), $_[0]->get_script_version());
}
sub check_graph_version {
	return 9 if $_[0]->is_3120();
	return gg_version::graph_ver_by_ver($_[0]->get_version());
}
sub level {
	if ($_[0]->get_flag & FL_LEVEL_SPAWN) {
		return 1;
	}
	return 0;
};
sub get_level_id {
	foreach my $level (reverse @{$_[0]->{sections_list}}) {
		if ($_[1] >= $_[0]->value($level, 'gvid0')) {
			return $_[0]->value($level, 'id')
		}
	}
	return undef;
}
sub read_service_chunk {
	my $self = shift;
	my ($cf) = @_;
	if ($cf->find_chunk(5)) {
		print "reading service information...\n";
		($self->{idx_file}) = unpack('Z*', ${$cf->r_chunk_data()});
		$cf->close_found_chunk();
	}
}
sub write_service_chunk {
	my $self = shift;
	my ($cf) = @_;
	
	if ($self->idx()){
		print "writing service information...\n";
		my $idx_name;
		if ($self->idx() eq '') {
			$idx_name = 'spawn_ids.ltx';
		} else {
			$idx_name = $self->idx();
		}
		$cf->w_chunk(5, pack('Z*', $idx_name));
	}
}
sub write_unknown_section {
	my $fh = IO::File->new('unk_chunk.bin', 'w');
	$fh->write(${$_[0]}, length(${$_[0]}));
	$fh->close();
}
#######################################################################
package main;
use strict;
use warnings;
use Getopt::Long;
use File::Path;
use stkutils::scan;
use stkutils::debug 'fail';
use stkutils::graph;
use stkutils::chunked;
use Cwd;
use Benchmark;
use constant FL_LEVEL_SPAWN => 0x01;
use constant FL_NO_FATAL => 0x10;
#use diagnostics;
#$SIG{__WARN__} = sub {print @_; die};

my $VERSION = 1.25;

# creating all_spawn object
my $spawn = all_spawn->new();

# parsing command line to obtain launch keys
my $config = $spawn->{config};
GetOptions(
	# main options
	'decompile:s' => \&process_glob_opt,
	'compile:s' => \&process_glob_opt,
	'split:s' => \&process_glob_opt,
	'convert=s' => \&process_glob_opt,
	'parse=s' => \&process_glob_opt,	
	# common options
	'out=s' => \&process_common_opts,
	'af' => \&process_common_opts,			# only for -d è -c
	'way' => \&process_common_opts,			# for -split and -parse
	'scan_dir=s' => \&process_common_opts,
	'graph_dir:s' => \&process_common_opts,	# useless with -parse and -c and while reading cs/cop spawn
	'level_spawn' => \&process_common_opts,	# can't use with -split and -parse
	'nofatal' => \&process_common_opts,
	# compile options
	'f=s' => \$config->{compile}->{flags},
	'idx:s' => \$config->{compile}->{idx_file},	
	# split options
	'use_graph' => \$config->{split}->{use_graph},
	# convert options
	'version=i' => \$config->{convert}->{new_version},
	'ini=s' => \$config->{convert}->{ini},
	# parse options
	'old=i' => \$config->{parse}->{old_gvid},
	'new=i' => \$config->{parse}->{new_gvid},
) or die usage();
my $common = $config->{common};
my $wd = getcwd();

print "Universal ACDC v.$VERSION\n";

# scanning config folder to obtain section-class correspondence
if ((exists $common->{scan_dir}) && !::is_alredy_scanned()) {
	my $temp = all_spawn->new();
	my $fh = stkutils::chunked->new($common->{src}, 'r') or fail(__PACKAGE__, __LINE__, '', 'cannot open '.$common->{src});
	$temp->read_service_chunk($fh) if !defined $common->{level_spawn};
	stkutils::scan->launch($common->{scan_dir}, $temp->{idx_file});
	$temp->DESTROY();
}

my $ini = stkutils::ini_file->new('sections.ini', 'r') if ::with_scan();
$common->{sections_ini} = $ini;

# set up flags
$spawn->set_flag(FL_LEVEL_SPAWN) if defined $common->{level_spawn};
$spawn->set_flag(FL_NO_FATAL) if defined $common->{nofatal};

# go to proper mode
SWITCH: {
	$spawn->mode() eq 'decompile' && do {decompile();last;};
	$spawn->mode() eq 'compile' && do {compile();last;};
	$spawn->mode() eq 'convert' && do {convert();last;};
	$spawn->mode() eq 'split' && do {splitting();last;};
	$spawn->mode() eq 'parse' && do {parse();last;};
}
print "done!\n";
sub process_glob_opt {
	fail(__PACKAGE__, __LINE__, '', 'You can use only one global option. See -help or -h to learn the syntax') if $spawn->get_src();
	$config = $spawn->{config};
	$config->{mode} = $_[0];
	$config->{common}->{src} = $_[1];
}
sub process_common_opts {
	fail(__PACKAGE__, __LINE__, '', 'No global options') unless exists $config->{common}->{src};
	$config->{common}->{$_[0]} = $_[1];
	if ($_[0] eq 'out') {
		my @path = split /\/|\\/, $_[1];
		if ($#path > 0) {
			delete $path[$#path];
			File::Path::mkpath(join('/',@path), 0);
		}
	}
}
sub decompile {
	check_spawn_version();
	print "opening $common->{src}...\n";
	my $t1 = new Benchmark;
	unlink 'guids.ltx';
	$spawn->read();	
	my $t2 = new Benchmark;
	read_graph() if (!defined $spawn->{graph_data} && !defined $common->{level_spawn}); 
	create_outdir($common->{out});
	print "exporting alife objects...\n";	
	$spawn->export('all.ltx');
	print timestr(timediff($t2, $t1));
}
sub compile {
	# handles flags of sections (i.e. [4569]: f1)
	if (defined $config->{compile}->{flags}) {
		foreach my $flag (split /,/, $config->{compile}->{flags}) {
			fail(__PACKAGE__.'::compile', __LINE__, '', "bad flag '$flag'\n") unless $flag =~ /\s*(\w+)\s*/;
			$config->{compile}->{flags_hash}{$1} = 1;
		}
	}
	if ($common->{src} ne '') {
		chdir $common->{src} or fail(__PACKAGE__.'::compile', __LINE__, '', 'cannot change dir to '.$common->{src});
	}
	$common->{out} = 'all.spawn.new' unless defined $common->{out};
	print "importing alife objects...\n";
	$spawn->import();
	# correct spawn versions if needed
	fix_versions();
	print "writing $common->{src}...\n";
	chdir $wd or fail(__PACKAGE__.'::compile', __LINE__, '', 'cannot change path to '.$wd);
	$spawn->write();
}
sub convert {
	# check existance of proper keys
	fail(__PACKAGE__, __LINE__, '', 'define new spawn version for converting spawn') unless exists $config->{convert}->{new_version};
	if (substr($common->{src}, -5) eq 'spawn') {
		check_spawn_version();
		print "opening $common->{src}...\n";
		unlink 'guids.ltx';
		$spawn->read();	
		read_graph() if !defined $spawn->{graph_data}; 
		$common->{out} = $common->{src}.'.converted';
		process_converting();
		$spawn->write();	
	} elsif (substr($common->{src}, -3) eq 'ltx') {
		$common->{out} = 'converted' unless defined $common->{out};
		print "importing alife objects...\n";
		$spawn->import_level($spawn->get_src());
		fix_versions();
		process_converting();
		print "exporting alife objects...\n";
		$spawn->export_level($spawn->get_out());		
	} else {
		fail(__PACKAGE__, __LINE__, '', 'Trouble with spawn converting: cant recognize type of file - text or binary');
	}	
}
sub splitting {
	# check existance of proper keys
	$common->{out} = 'levels' unless exists $common->{out};
	check_spawn_version();
	print "opening $common->{src}...\n";
	unlink 'guids.ltx';
	$spawn->read();
	read_graph() if !defined $spawn->{graph_data}; 
	if ($spawn->use_graph()) {
		create_outdir($common->{out});
		$spawn->{graph}->read_edges();
		$spawn->prepare_graph_points();
		prepare_level_folders($spawn->{graph});
	} else {
		chdir $common->{out} or fail(__PACKAGE__.'::splitting', __LINE__, '', 'you must define levels folder using -out');
		$spawn->read_level_spawns();
	}
	$spawn->write_splitted_spawns();
	$spawn->split_ways() if $spawn->way();
}
sub parse {
	# check existance of proper keys
	fail(__PACKAGE__, __LINE__, '', 'define old gvid0 for spawn parsing') unless exists $config->{parse}->{old_gvid};
	fail(__PACKAGE__, __LINE__, '', 'define new gvid0 for spawn parsing') unless exists $config->{parse}->{new_gvid};
	print "parsing $common->{src}...\n";
	$spawn->import_level($spawn->get_src());
	$common->{out} = 'parsed_spawn' unless defined $common->{out};
	create_outdir($common->{out});
	fix_versions();	
	foreach my $object (@{$spawn->{alife_objects}}) {
		$object->{cse_object}->{game_vertex_id} += ($spawn->get_new_gvid() - $spawn->get_old_gvid());
	}	
	print "exporting $common->{out}...\n";
	my @out = split /\//, $spawn->get_src();
	$spawn->export_level($out[$#out]);
	$spawn->parse_way($out[$#out]);	
}
chdir $wd;
if (::with_scan()) {
	if ($spawn->get_version() == 118 && $spawn->get_script_version() == 5 && ($config->{mode} ne 'compile') && ($config->{mode} ne 'parse')) {
		refresh_sections();
	} else {
		$ini->close();
	}
}

# service subs
sub is_alredy_scanned {
	if (-e 'sections.ini') {
		my $size = -s 'sections.ini';
		return $size > 0;
	}
	return 0;
}
sub check_spawn_version {
	print "checking version of $common->{src}...\n";	
	my $fh = IO::File->new($common->{src}, 'r') or fail(__PACKAGE__, __LINE__, '', 'cannot open '.$common->{src});
	binmode $fh;
	my $data;
	$fh->read($data, 0x12C) or fail(__PACKAGE__, __LINE__, '$fh->read($data, 0x12C)', 'cannot read '.$common->{src});
	$fh->close();
	my $table = ();
	if ($spawn->level()) {
			(
			$table->{garb_1},
			$table->{section_name},
			$table->{name},
			$table->{garb_2},
			$table->{version},
			$table->{script_version},
			$table->{backup},
		) = unpack('a[10]Z*Z*a[36]vvv', $data);
	} else {
		($table->{switch}, $table->{header_size}) = unpack('VV',$data);
		if ($table->{switch} == 0) {
			if ($table->{header_size} == 0x2c) {
				(
					$table->{garb_1},
					$table->{section_name},
					$table->{name},
					$table->{garb_2},
					$table->{version},
					$table->{script_version},
					$table->{backup},
				) = unpack('a[118]Z*Z*a[36]vvv', $data);
			} else {
				(
					$table->{garb_1},
					$table->{section_name},
					$table->{name},
					$table->{garb_2},
					$table->{version},
					$table->{script_version},
					$table->{backup},
				) = unpack('a[76]Z*Z*a[36]vvv', $data);
			}
		} else {
			(
				$table->{garb_1},
				$table->{section_name},
				$table->{name},
				$table->{garb_2},
				$table->{version},
				$table->{script_version},
			) = unpack('a[32]Z*Z*a[36]vv', $data);	
		}	
	}
	$table->{script_version} = $table->{backup} if $table->{script_version} == 0xffff;
	$table->{script_version} = 0 if $table->{version} <= 0x45;
	my $build = (gg_version::build_by_version($table->{version}, $table->{script_version}) or 'unknown,  spawn ver. '.$table->{version}.'');
	if ($table->{version} == 118 && $table->{script_version} == 6) {
		my $fh = stkutils::chunked->new($common->{src}, 'r');
		if ($fh->find_chunk(0x4)) {
			print "	This is a spawn of S.T.A.L.K.E.R. xrCore build 3120\n";
			$fh->close_found_chunk();
		} else {
			print "	This is a spawn of S.T.A.L.K.E.R. $build\n";
		}
		$fh->close();
	} else {
		print "	This is a spawn of S.T.A.L.K.E.R. $build\n";
	}
	$spawn->set_version($table->{version});
	$spawn->set_script_version($table->{script_version});
}
sub prepare_level_folders {
	my $graph = shift;
	print "preparing level folders...\n";
	foreach my $level (values %{$graph->{level_by_guid}}) {
		File::Path::mkpath($level, 0);
	}
}
sub create_outdir {
	defined $_[0] && do {
		File::Path::mkpath($_[0], 0);
		chdir $_[0] or fail(__PACKAGE__, __LINE__, '', 'cannot change path to '.$_[0]);
	};
}
sub with_scan {return ((defined $common->{scan_dir}) || (-e 'sections.ini'))}
sub fix_versions {
	my $ver = 0;
	my $scr_ver = 0;
	foreach (@{$spawn->{alife_objects}}) {
		next unless $_->{cse_object}->{section_name} eq 'actor';
		fail(__PACKAGE__.'::fix_versions', __LINE__, 'defined $_->{cse_object}->{version}', 'you must define version in actor section') if $_->{cse_object}->{version} == 0;
		$ver = $_->{cse_object}->{version};
		$scr_ver = $_->{cse_object}->{script_version};
		$scr_ver = gg_version::scr_ver_by_version($ver) if !defined $scr_ver;
		last;
	}
	if ($ver == 0) {
		$ver = $spawn->{alife_objects}[0]->{cse_object}->{version};
		$scr_ver = $spawn->{alife_objects}[0]->{cse_object}->{script_version};
	}
	fail(__PACKAGE__.'::fix_versions', __LINE__, 'defined $_->{cse_object}->{version}', 'you must define version in first section') if $ver == 0;
	foreach (@{$spawn->{alife_objects}}) {
		next if $_->{cse_object}->{version} == $ver;
		$_->{cse_object}->{version} = $ver;
		$_->{cse_object}->{script_version} = $scr_ver;
	}
}
sub process_converting {
	print "converting spawn...\n";
	$spawn->prepare_objects();
	foreach my $object (@{$spawn->{alife_objects}}) {
		next unless defined $object;
		$object->{cse_object}->{version} = $config->{convert}->{new_version};
		$object->{cse_object}->{script_version} = gg_version::scr_ver_by_version($config->{convert}->{new_version});
		my $sName = lc($object->{cse_object}->{section_name});
		my $class_name;
		$class_name = $object->{cse_object}->{ini}->value('sections', "'$sName'") if defined $object->{cse_object}->{ini};
		defined $class_name or $class_name = stkutils::scan->get_class($sName) or fail(__PACKAGE__.'::_read_m_spawn', __LINE__, 'defined $class_name', 'unknown class for section '.$object->{cse_object}->{section_name});
		bless $object->{cse_object}, $class_name;
		fail(__PACKAGE__.'::convert', __LINE__, '', 'unknown clsid '.$class_name.' for section '.$object->{cse_object}->{section_name}) if !UNIVERSAL::can($object->{cse_object}, 'state_read');
		# handle SCRPTZN
		if ($object->{cse_object}->{version} > 124){
			bless $object->{cse_object}, 'se_sim_faction' if ($sName eq 'sim_faction');
		}	
		# handle wrong classes for weapon in ver 118
		if ($object->{cse_object}->{version} == 118 && $object->{cse_object}->{script_version} > 5){
			# soc
			bless $object->{cse_object}, 'cse_alife_item_weapon_magazined' if $sName =~ /ak74u|vintore/;
		}
		fail(__PACKAGE__.'::convert', __LINE__, '', 'unknown clsid '.$class_name.' for section '.$object->{cse_object}->{section_name}) if !UNIVERSAL::can($object->{cse_object}, 'state_import');	
		$object->init_abstract();
		$object->init_object();
	}
	$spawn->print_harm_objects() if $#{$spawn->{harm_objects}} != -1;
	$spawn->print_excluded_objects() if $#{$spawn->{excluded_objects}} != -1;	
}
sub read_graph {
	my $graph_file;
	if (defined $spawn->graph_dir()) {
		$graph_file = IO::File->new($spawn->graph_dir().'\\game.graph', 'r') or fail(__PACKAGE__.'::read_graph', __LINE__, '', "$!".$spawn->graph_dir().'\\game.graph');
	} else {
		$graph_file = IO::File->new('game.graph', 'r') or fail(__PACKAGE__.'::read_graph', __LINE__, '', "$! game.graph");
	}
	binmode $graph_file;
	my $graph_data = '';
	$graph_file->read($graph_data, ($graph_file->stat())[7]);
	$graph_file->close();
	$spawn->{graph_data} = $graph_data;
	$spawn->{graph} = stkutils::graph->new(\$graph_data);
	$spawn->{graph}->{gg_version} = gg_version::graph_build($spawn->get_version(), $spawn->get_script_version());
	$spawn->{graph}->decompose();
	$spawn->{graph}->read_vertices();
	$spawn->{graph}->show_guids('guids.ltx');
};
sub is_flag_defined {return (defined $config->{compile}->{flags_hash}{$_[0]}) ? 1 : 0};
sub refresh_sections {
	my $ini_new = IO::File->new('sections.new.ini', 'w') or fail(__PACKAGE__.'::refresh_sections', __LINE__, '', "$! sections.new.ini\n");
	print $ini_new "[sections]\n";
	foreach my $section (keys %{$common->{sections_ini}->{sections_hash}{'sections'}}) {
		print $ini_new "$section = $common->{sections_ini}->{sections_hash}{'sections'}{$section}\n";
	}
	$ini_new->close();
	$ini->close();
	unlink 'sections.ini' if -e 'sections.new.ini';
	rename 'sections.new.ini', 'sections.ini';
}
sub usage {
	return <<END
	BAD CALL SYNTAX!
S.T.A.L.K.E.R. all.spawn compiler/decompiler

Decompilation: universal_acdc.pl -d <spawn_file> [common_options]
	-d <spawn_file> - path to spawn file
	common_options - see below

Compilation: universal_acdc.pl -compile <dir> [-idx <index_file>] [-f <flag1,flag2,...>] [common_options]
	-compile <dir> - path to folder with unpacked spawn.
	-idx <index_file> - create a file with entity id's
	common_options - see below

Converting: universal_acdc.pl -convert <file> -version <new_version> [common_options]
	-convert <file> - file to convert
	-version <new_version> - new spawn version
	common_options - see below
	
Parsing vertices: universal_acdc.pl -parse <file> -old <old_gvid0> -new <new_gvid0> [-way] [common_options]
	-parse <file> - file to parse
	-old <old_gvid0> - old start game_vertex_id
	-new <new_gvid0> - new start game_vertex_id
	-way - force way parsing
	common_options - see below

Splitting spawn: universal_acdc.pl -split <file> [-use_graph] [-way] [common_options]
	-split <file> - file to split
	-use_graph - use game.graph for graph point recovering
	-way - force level.game creating
	common_options - see below

Common options:
	-out <file> - outdir/outfile:
		for decompile, parse - result folder
		for compile, convert - result file
		for split - result folder with levels
	-scan <scan_dir> - path to config folder
	-g <graph_dir> - path to game.graph folder
	-level - force level.spawn unpacking
	-af - force section2.bin unpacking
	-nofatal - replace FATAL ERROR generation to WARNING generation
END
}
#######################################################################