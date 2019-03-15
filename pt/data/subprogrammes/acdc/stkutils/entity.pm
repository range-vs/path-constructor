#!perl
# last edited: 19 Sep 2011
#######################################################################
package stkutils::entity;
use strict;
use stkutils::scan;
use stkutils::data_packet;
use stkutils::debug 'fail';
use constant FL_LEVEL_SPAWN => 0x01;
use constant FL_IS_2942 => 0x04;
use constant FL_IS_25XX => 0x08;
use constant FL_NO_FATAL => 0x10;

sub new {
	my $class = shift;
	my $self = {};
	$self->{cse_object} = {};
	$self->{cse_object}->{flags} = 0;
	$self->{cse_object}->{ini} = undef;
	$self->{markers} = {};
	bless $self, $class;
	return $self;
}
sub init_abstract {
	my $self = shift;
	cse_abstract::init($self->{cse_object});
}
sub init_object {
	my $self = shift;
	$self->{cse_object}->init();
}
sub read {
	my $self = shift;
	my ($cf, $version) = @_;
	if (!$self->level()) {
		if ($version > 79) {
			while (1) {
				my ($index, $size) = $cf->r_chunk_open();
				defined($index) or last;
				my $id;
				if ($index == 0) {
					if ($version < 95) {
						$self->read_new($cf);
					} else {
						$id = unpack('v', ${$cf->r_chunk_data()});
					}
				} elsif ($index == 1) {
					if ($version < 95) {
						$id = unpack('v', ${$cf->r_chunk_data()});
					} else {
						$self->read_new($cf);
					}
				}
				$cf->r_chunk_close();
			}	
		} else {
			my $data = ${$cf->r_chunk_data()};
			my $size16 = unpack('v', substr($data, 0, 2));
			my $st_packet = stkutils::data_packet->new(\substr($data, 2, $size16));
			my $up_packet = stkutils::data_packet->new(\substr($data, $size16 + 4));
			$self->_read_m_spawn($st_packet);
			$self->_read_m_update($up_packet);
		}
	} else {
		$self->_read_m_spawn(stkutils::data_packet->new($cf->r_chunk_data()));
	}
}
sub read_new {
	my $self = shift;
	my ($cf) = @_;
	while (1) {
		my ($index, $size) = $cf->r_chunk_open();
		defined($index) or last;
		my $data = ${$cf->r_chunk_data()};
		my $size16 = unpack('v', substr($data, 0, 2));
		$size16 == ($size - 2) or fail(__PACKAGE__.'::read', __LINE__, '$size16 == ($size - 2)', 'alife object size mismatch');
		my $packet = stkutils::data_packet->new(\substr($data, 2));
		if ($index == 0) {
			$self->_read_m_spawn($packet);
		} elsif ($index == 1) {
			$self->_read_m_update($packet);
		}
		$cf->r_chunk_close();
	}
}
sub _read_m_spawn {
	my $self = shift;
	my ($packet) = @_;
	$self->init_abstract();
	cse_abstract::state_read($self->{cse_object}, $packet);
	my $sName = lc($self->{cse_object}->{section_name});
	my $class_name;
	$class_name = $self->{cse_object}->{ini}->value('sections', "'$sName'") if defined $self->{cse_object}->{ini};
	defined $class_name or $class_name = stkutils::scan->get_class($sName) or fail(__PACKAGE__.'::_read_m_spawn', __LINE__, 'defined $class_name', 'unknown class for section '.$self->{cse_object}->{section_name});
	bless $self->{cse_object}, $class_name;
	fail(__PACKAGE__.'::_read_m_spawn', __LINE__, '', 'unknown clsid '.$class_name.' for section '.$self->{cse_object}->{section_name}) if !UNIVERSAL::can($self->{cse_object}, 'state_read');
	# handle SCRPTZN
	if ($self->{cse_object}->{version} > 124){
		bless $self->{cse_object}, 'se_sim_faction' if ($sName eq 'sim_faction');
	}	
	# handle wrong classes for weapon in ver 118
	if ($self->{cse_object}->{version} == 118 && $self->{cse_object}->{script_version} > 5){
		# soc
		bless $self->{cse_object}, 'cse_alife_item_weapon_magazined' if $sName =~ /ak74u|vintore/;
	}
	$self->init_object();
	$self->{cse_object}->state_read($packet);
	# shut up warnings for smart covers with extra data (acdccop bug)
	$packet->resid() == 0 or return if ((ref($self->{cse_object}) eq 'se_smart_cover') && ($packet->resid() % 2 == 0));
	# correct reading check
	$packet->resid() == 0 or stkutils::debug::warn(__PACKAGE__.'::_read_m_spawn', __LINE__, '$packet->resid() == 0', 'state data left ['.$packet->resid().'] in entity '.$self->{cse_object}->{name});
}
sub _read_m_update {
	my $self = shift;
	my ($packet) = @_;
	cse_abstract::update_read($self->{cse_object}, $packet);
	UNIVERSAL::can($self->{cse_object}, 'update_read') && do {$self->{cse_object}->update_read($packet)};
	$packet->resid() == 0 or $self->error(__PACKAGE__.'::_read_m_update', __LINE__, '$packet->resid() == 0', 'update data left ['.$packet->resid().'] in entity '.$self->{cse_object}->{name});		
}
sub write {
	my $self = shift;
	my ($cf, $object_id) = @_;
	if (!$self->level()) {
		if ($self->version() > 79) {
			if ($self->version() > 94) {
				$cf->w_chunk(0, pack('v', $object_id));
				$cf->w_chunk_open(1);
			} else {
				$cf->w_chunk_open(0);
			}
			
			$cf->w_chunk_open(0);
			$self->_write_m_spawn($cf, $object_id);
			$cf->w_chunk_close();
			
			$cf->w_chunk_open(1);
			$self->_write_m_update($cf);
			$cf->w_chunk_close();

			$cf->w_chunk_close();
			if ($self->version() <= 94) {
				$cf->w_chunk(1, pack('v', $object_id));
			}	
		} else {
			$self->_write_m_spawn($cf, $object_id);
			$self->_write_m_update($cf);
		}
	} else {
		$object_id = 0xFFFF;
		if ($self->{cse_object}->{section_name} eq 'graph_point') { 
			$object_id = 0xCCCC;
		}
		$self->_write_m_spawn($cf, $object_id);
	}
}
sub _write_m_spawn {
	my $self = shift;
	my ($cf, $object_id) = @_;
	my $obj_packet = stkutils::data_packet->new();
	$self->{cse_object}->state_write($obj_packet);
	my $abs_packet = stkutils::data_packet->new();
	cse_abstract::state_write($self->{cse_object}, $abs_packet, $object_id, $obj_packet->length() + 2);
	$cf->w_chunk_data(pack('v', $abs_packet->length() + $obj_packet->length())) if !$self->level();
	$cf->w_chunk_data($abs_packet->data());
	$cf->w_chunk_data($obj_packet->data());
}
sub _write_m_update {
	my $self = shift;
	my ($cf) = @_;
	my $obj_upd_packet = stkutils::data_packet->new();
	UNIVERSAL::can($self->{cse_object}, 'update_write') && do {$self->{cse_object}->update_write($obj_upd_packet);};
	my $abs_upd_packet = stkutils::data_packet->new();
	cse_abstract::update_write($self->{cse_object}, $abs_upd_packet);
	$cf->w_chunk_data(pack('v', $abs_upd_packet->length() + $obj_upd_packet->length()));
	$cf->w_chunk_data($abs_upd_packet->data());
	$cf->w_chunk_data($obj_upd_packet->data());
}
sub import_ltx {
	my $self = shift;
	my ($if, $section, $ini) = @_;
	$self->init_abstract();
	cse_abstract::state_import($self->{cse_object}, $if, $section);
	my $sName = lc($self->{cse_object}->{section_name});
	my $class_name;
	$class_name = $ini->value('sections', "'$sName'") if defined $ini;
	defined $class_name or $class_name = stkutils::scan->get_class($sName) or fail(__PACKAGE__.'::import_ltx', __LINE__, 'defined $class_name', 'unknown class for section '.$self->{cse_object}->{section_name});
	bless $self->{cse_object}, $class_name;
	fail(__PACKAGE__.'::import_ltx', __LINE__, '', 'unknown clsid '.$class_name.' for section '.$self->{cse_object}->{section_name}) if !UNIVERSAL::can($self->{cse_object}, 'state_import');
	if ($self->{cse_object}->{version} < 122){
		bless $self->{cse_object}, 'cse_alife_space_restrictor' if ($class_name eq 'se_sim_faction');
	}	
	if ($self->{cse_object}->{version} == 118 && $self->{cse_object}->{script_version} > 5){
		bless $self->{cse_object}, 'cse_alife_item_weapon_magazined' if $sName =~ /ak74u|vintore/;
	}
	$self->init_object();
	$self->{cse_object}->state_import($if, $section);
	UNIVERSAL::can($self->{cse_object}, 'update_import') && do {$self->{cse_object}->update_import($if, $section)} if !$self->level();
}
sub export_ltx {
	my $self = shift;
	my ($if, $id) = @_;

	my $fh = $if->{fh};
	print $fh "[$id]\n";
	cse_abstract::state_export($self->{cse_object}, $if);
	$self->{cse_object}->state_export($if);
	UNIVERSAL::can($self->{cse_object}, 'update_export') && do {$self->{cse_object}->update_export($if)} if !$self->level();
	print $fh "\n;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n\n";	
}
sub init_properties {
	my $self = shift;
	foreach my $p (@_) {
		next if defined $self->{$p->{name}};
		if (defined $p->{default}) {
			if (ref($p->{default}) eq 'ARRAY') {
				@{$self->{$p->{name}}} = @{$p->{default}};
			} else {
				$self->{$p->{name}} = $p->{default};
			}
		}
	}
}
sub version {
	return $_[0]->{cse_object}->{version};
}
sub level {
	if ($_[0]->{cse_object}->{flags} & FL_LEVEL_SPAWN) {
		return 1;
	}
	return 0;
}
sub set_save_marker {
	my $self = shift;
	my $packet = shift;
	my $mode = shift;
	my $check = shift;
	my $name = shift;
	if ($check) {
		die unless defined($self->{markers}{$name});
		if ($mode eq 'save') {
			my $diff = $packet->w_tell() - $self->{markers}{$name};
			die unless $diff > 0;
			$packet->pack('v', $diff);
		} else {
			my $diff = $packet->r_tell() - $self->{markers}{$name};
			die unless $diff > 0;
			my ($diff1) = $packet->unpack('v', 2);
			die unless $diff == $diff1;
		}
	} else {
		if ($mode eq 'save') {
			$self->{markers}{$name} = $packet->w_tell();
		} else {
			$self->{markers}{$name} = $packet->r_tell();
		}
	}
}
sub error {
	if (!($_[0]->{cse_object}->{flags} & FL_NO_FATAL)) {
		fail($_[1], $_[2], $_[3], $_[4])
	} else {
		stkutils::debug::warn($_[1], $_[2], $_[3], $_[4])
	}
}
#########################################################
package cse_abstract;
use strict;
use stkutils::debug 'fail';
####	enum s_gameid
#use constant	GAME_ANY		=> 0;
#use constant	GAME_SINGLE		=> 0x01;
#use constant	GAME_DEATHMATCH	=> 0x02;
#use constant	GAME_CTF		=> 0x03;
#use constant	GAME_ASSAULT	=> 0x04;
#use constant	GAME_CS			=> 0x05;
#use constant	GAME_TEAMDEATHMATCH	=> 0x06;
#use constant	GAME_ARTEFACTHUNT	=> 0x07;
#use constant	GAME_LASTSTANDING	=> 0x64;
#use constant	GAME_DUMMY		=> 0xFF;
####	enum s_flags
use constant	FL_SPAWN_ENABLED		=> 0x01;
use constant	FL_SPAWN_ON_SURGE_ONLY		=> 0x02;
use constant	FL_SPAWN_SINGLE_ITEM_ONLY	=> 0x04;
use constant	FL_SPAWN_IF_DESTROYED_ONLY	=> 0x08;
use constant	FL_SPAWN_INFINITE_COUNT		=> 0x10;
use constant	FL_SPAWN_DESTROY_ON_SPAWN	=> 0x20;
use constant properties_info => (
			{ name => 'dummy16',				type => 'h16',	default => 0x0001 },
			{ name => 'section_name',			type => 'sz',	default => '' },
			{ name => 'name',					type => 'sz',	default => '' },
			{ name => 's_gameid',				type => 'h8',	default => 0 },
			{ name => 's_rp',					type => 'h8',	default => 0xfe },
			{ name => 'position',				type => 'f32v3',default => [] },
			{ name => 'direction',				type => 'f32v3',default => [] },
			{ name => 'respawn_time',			type => 'h16',	default => 0 },
			{ name => 'unknown_id',				type => 'h16',	default => 0xffff },
			{ name => 'parent_id',				type => 'h16',	default => 0xffff },
			{ name => 'phantom_id',				type => 'h16',	default => 0xffff },
			{ name => 's_flags',				type => 'h16',	default => 0x21 },
			{ name => 'version',				type => 'u16',	default => 0 },
			{ name => 'cse_abstract__unk1_u16',	type => 'h16',	default => 0xFFFF },
			{ name => 'script_version',			type => 'u16',	default => 0 },
			{ name => 'spawn_probability',		type => 'f32',	default => 1.00 },
			{ name => 'spawn_flags',			type => 'u32',	default => 31 },
			{ name => 'spawn_control',			type => 'sz',	default => '' },
			{ name => 'max_spawn_count',		type => 'u32',	default => 1 },
			{ name => 'spawn_count',			type => 'u32',	default => 0 },
			{ name => 'last_spawn_time',		type => 'u8v8', default => [0,0,0,0,0,0,0,0] },
			{ name => 'min_spawn_interval',		type => 'u8v8', default => [0,0,0,0,0,0,0,0] },
			{ name => 'max_spawn_interval',		type => 'u8v8', default => [0,0,0,0,0,0,0,0] },	
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	my $self = shift;
	my ($packet) = @_;
	$packet->unpack_properties($self, (properties_info)[0]);
	fail(__PACKAGE__.'::state_read', __LINE__, 'M_SPAWN == dummy16', 'cannot open M_SPAWN!') if $self->{'dummy16'} != 1;
	$packet->unpack_properties($self, (properties_info)[1..11]);
	if ($self->{s_flags} & FL_SPAWN_DESTROY_ON_SPAWN) {
		$packet->unpack_properties($self, (properties_info)[12]);
	}
	if ($self->{version} > 120) {
		$packet->unpack_properties($self, (properties_info)[13]);
	}
	if ($self->{version} > 69) {
		$packet->unpack_properties($self, (properties_info)[14]);
	}
	my ($unused, $spawn_id);
	if ($self->{version} > 93) {
		($unused) = $packet->unpack('v', 2);
	} elsif ($self->{version} > 70) {
		($unused) = $packet->unpack('C', 1);
	}
	if ($self->{version} > 79) {
		($spawn_id) = $packet->unpack('v', 2);
	}
	if ($self->{version} < 112) {
		if ($self->{version} > 82) {
			$packet->unpack_properties($self, (properties_info)[15]);
		}
		if ($self->{version} > 83) {
			$packet->unpack_properties($self, (properties_info)[16..20]);
		}		
		if ($self->{version} > 84) {
			$packet->unpack_properties($self, (properties_info)[21..22]);
		}	
	}
	my $extended_size = $packet->unpack('v', 2);
}
sub state_write {
	my $self = shift;
	my ($packet, $spawn_id, $extended_size) = @_;
	$packet->pack_properties($self, (properties_info)[0..11]);
	if ($self->{s_flags} & FL_SPAWN_DESTROY_ON_SPAWN) {
		$packet->pack_properties($self, (properties_info)[12]);
	}
	if ($self->{version} > 120) {
		$packet->pack_properties($self, (properties_info)[13]);
	}
	if ($self->{version} > 69) {
		$packet->pack_properties($self, (properties_info)[14]);
	}
	if ($self->{version} > 93) {
		$packet->pack('v', 0);
	} elsif ($self->{version} > 70) {
		$packet->pack('C', 0);
	}
	if ($self->{version} > 79) {
		$packet->pack('v', $spawn_id);
	}
	if ($self->{version} < 112) {
		if ($self->{version} > 82) {
			$packet->pack_properties($self, (properties_info)[15]);
		}
		if ($self->{version} > 83) {
			$packet->pack_properties($self, (properties_info)[16..20]);
		}		
		if ($self->{version} > 84) {
			$packet->pack_properties($self, (properties_info)[21..22]);
		}	
	}
	$packet->pack('v', $extended_size);
}
sub update_read {
	my ($size) = $_[1]->unpack('v', 2);
	fail(__PACKAGE__.'::update_read', __LINE__, '$size == 0', 'unexpected size of CSE_Abstract M_UPDATE packet') unless $size == 0;
}
sub update_write {
	$_[1]->pack('v', 0);
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_graph_point;
use strict;
use constant properties_info => (
	{ name => 'connection_point_name',	type => 'sz',	default => '' },
	{ name => 'connection_level_id',	type => 's32',	default => -1 },
	{ name => 'connection_level_name',	type => 'sz',	default => '' },
	{ name => 'location0',			type => 'u8',	default => 0 },	
	{ name => 'location1',			type => 'u8',	default => 0 },
	{ name => 'location2',			type => 'u8',	default => 0 },	
	{ name => 'location3',			type => 'u8',	default => 0 },
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	$_[1]->unpack_properties($_[0], (properties_info)[0]);
	if ($_[0]->{version} > 33) {
		$_[1]->unpack_properties($_[0], (properties_info)[2]);
	} else {
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
	}
	$_[1]->unpack_properties($_[0], (properties_info)[3..6]);
}
sub state_write {
	$_[1]->pack_properties($_[0], (properties_info)[0]);
	if ($_[0]->{version} > 33) {
		$_[1]->pack_properties($_[0], (properties_info)[2]);
	} else {
		$_[1]->pack_properties($_[0], (properties_info)[1]);
	}
	$_[1]->pack_properties($_[0], (properties_info)[3..6]);
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_shape;
use strict;
use constant properties_info => (
	{ name => 'shapes', type => 'shape', default => {} },
);
sub state_read {
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_visual;
use strict;
use constant flObstacle	=> 0x01;
use constant properties_info => (
	{ name => 'visual_name',	type => 'sz',	default => '' },
	{ name => 'visual_flags',	type => 'h8',	default => 0 },
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	$_[1]->unpack_properties($_[0], (properties_info)[0]);
	if ($_[0]->{version} >= 104) {
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
	}
}
sub state_write {
	$_[1]->pack_properties($_[0], (properties_info)[0]);
	if ($_[0]->{version} >= 104) {
		$_[1]->pack_properties($_[0], (properties_info)[1]);
	}
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_object_dummy;
use strict;
use constant properties_info => (
	{ name => 'cse_alife_object_dummy__unk1_u8',	type => 'u8',	default => 0 },
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
	cse_visual::init(@_);
}
sub state_read {
	$_[1]->unpack_properties($_[0], properties_info);
	cse_visual::state_read(@_);
}
sub state_write {
	$_[1]->pack_properties($_[0], properties_info);
	cse_visual::state_write(@_);
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
	cse_visual::state_import(@_);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	cse_visual::state_export(@_);
}
#######################################################################
package cse_motion;
use strict;
use constant properties_info => (
	{ name => 'motion_name', type => 'sz', default => '' },
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_ph_skeleton;
use strict;
use constant properties_info => (
	{ name => 'skeleton_name',	type => 'sz',	default => '$editor' },
	{ name => 'skeleton_flags',	type => 'u8',	default => 0 },	
	{ name => 'source_id',		type => 'h16',	default => 0xffff },
#	{ name => 'bones_mask',		type => 'u8v8',	default => [0,0,0,0,0,0,0,0] },
#	{ name => 'root_bone',		type => 'u16',	default => 0 },
#	{ name => 'ph_angular_velosity',		type => 'f32v3',	default => [0,0,0] },
#	{ name => 'ph_linear_velosity',		type => 'f32v3',	default => [0,0,0] },
#	{ name => 'bone_count',		type => 'u16',	default => 0 },
#	{ name => 'ph_position',		type => 'q8v3',	default => [0,0,0] },
#	{ name => 'ph_rotation',		type => 'q8v4',	default => [0,0,0,0] },
#	{ name => 'enabled',		type => 'u8', default => 1},
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_target_cs_cask; 																
use strict;
use constant properties_info => (
	{ name => 'cse_target_cs_cask__unk1_u8',	type => 'u8',	default => 0 },
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_target_cs_base; 																
use strict;
use constant properties_info => (
	{ name => 'cse_target_cs_base__unk1_f32',	type => 'f32',	default => 0 },
	{ name => 'team_id',	type => 'u8'},
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_spawn_group; 													
use strict;
use constant properties_info => (
	{ name => 'group_probability', type => 'f32', default => 1.0},
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	if ($_[0]->{version} <= 79) {
		$_[1]->unpack_properties($_[0], properties_info);
	}
}
sub state_write {
	if ($_[0]->{version} <= 79) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_object;
use strict;
use constant flUseSwitches		=> 0x00000001;
use constant flSwitchOnline		=> 0x00000002;
use constant flSwitchOffline		=> 0x00000004;
use constant flInteractive		=> 0x00000008; 
use constant flVisibleForAI		=> 0x00000010;
use constant flUsefulForAI		=> 0x00000020;
use constant flOfflineNoMove		=> 0x00000040;
use constant flUsedAI_Locations		=> 0x00000080;
use constant flUseGroupBehaviour	=> 0x00000100;
use constant flCanSave			=> 0x00000200;
use constant flVisibleForMap		=> 0x00000400;
use constant flUseSmartTerrains		=> 0x00000800;
use constant flCheckForSeparator	=> 0x00001000;
use constant flCorpseRemoval		=> 0x00002000;
use constant properties_info => (
			{ name => 'cse_alife_object__unk1_u8',	type => 'u8',	default => 0 },
			{ name => 'spawn_probability',	type => 'f32',	default => 1.00 },
			{ name => 'spawn_id',	type => 's32',	default => -1 },
			{ name => 'cse_alife_object__unk2_u16',	type => 'u16',	default => 0 },	
			{ name => 'game_vertex_id',	type => 'u16',	default => 0xffff },
			{ name => 'distance',		type => 'f32',	default => 0.0 },
			{ name => 'direct_control',	type => 'u32',	default => 1 },
			{ name => 'level_vertex_id',	type => 'u32',	default => 0xffffffff },
			{ name => 'cse_alife_object__unk3_u16',	type => 'u16',	default => 0 },
			{ name => 'spawn_control',		type => 'sz',	default => '' },
			{ name => 'object_flags',	type => 'h32',	default => 0 },
			{ name => 'custom_data',	type => 'sz',	default => ''},	
			{ name => 'story_id',		type => 's32',	default => -1 },
			{ name => 'spawn_story_id',		type => 's32',	default => -1 },
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	if ($_[0]->{version} <= 24) {
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
	} elsif (($_[0]->{version} > 24) && ($_[0]->{version} < 83)) {
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
	}
	if ($_[0]->{version} < 83) {
		$_[1]->unpack_properties($_[0], (properties_info)[2]);
	}
	if ($_[0]->{version} < 4) {
		$_[1]->unpack_properties($_[0], (properties_info)[3]);
	}
	$_[1]->unpack_properties($_[0], (properties_info)[4..5]);
	if ($_[0]->{version} >= 4) {
		$_[1]->unpack_properties($_[0], (properties_info)[6]);
	}
	if ($_[0]->{version} >= 8) {
		$_[1]->unpack_properties($_[0], (properties_info)[7]);
	}
	if (($_[0]->{version} > 22) && ($_[0]->{version} <= 79)) {
		$_[1]->unpack_properties($_[0], (properties_info)[8]);
	}
	if (($_[0]->{version} > 23) && ($_[0]->{version} <= 84)) {
		$_[1]->unpack_properties($_[0], (properties_info)[9]);
	}
	if ($_[0]->{version} > 49) {
		$_[1]->unpack_properties($_[0], (properties_info)[10]);
	}
	if ($_[0]->{version} > 57) {
		$_[1]->unpack_properties($_[0], (properties_info)[11]);
	}
	if ($_[0]->{version} > 61) {
		$_[1]->unpack_properties($_[0], (properties_info)[12]);
	}
	if ($_[0]->{version} > 111) {
		$_[1]->unpack_properties($_[0], (properties_info)[13]);
	}
}
sub state_write {
	if ($_[0]->{version} <= 24) {
		$_[1]->pack_properties($_[0], (properties_info)[0]);
	} elsif (($_[0]->{version} > 24) && ($_[0]->{version} < 83)) {
		$_[1]->pack_properties($_[0], (properties_info)[1]);
	}
	if ($_[0]->{version} < 83) {
		$_[1]->pack_properties($_[0], (properties_info)[2]);
	}
	if ($_[0]->{version} < 4) {
		$_[1]->pack_properties($_[0], (properties_info)[3]);
	}
	$_[1]->pack_properties($_[0], (properties_info)[4..5]);
	if ($_[0]->{version} >= 4) {
		$_[1]->pack_properties($_[0], (properties_info)[6]);
	}
	if ($_[0]->{version} >= 8) {
		$_[1]->pack_properties($_[0], (properties_info)[7]);
	}
	if (($_[0]->{version} > 22) && ($_[0]->{version} <= 79)) {
		$_[1]->pack_properties($_[0], (properties_info)[8]);
	}
	if (($_[0]->{version} > 23) && ($_[0]->{version} <= 84)) {
		$_[1]->pack_properties($_[0], (properties_info)[9]);
	}
	if ($_[0]->{version} > 49) {
		$_[1]->pack_properties($_[0], (properties_info)[10]);
	}
	if ($_[0]->{version} > 57) {
		$_[1]->pack_properties($_[0], (properties_info)[11]);
	}
	if ($_[0]->{version} > 61) {
		$_[1]->pack_properties($_[0], (properties_info)[12]);
	}
	if ($_[0]->{version} > 111) {
		$_[1]->pack_properties($_[0], (properties_info)[13]);
	}
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_dynamic_object;
use strict;
sub init {
	cse_alife_object::init(@_);
}
sub state_read {
	cse_alife_object::state_read(@_);
}
sub state_write {
	cse_alife_object::state_write(@_);
}
sub state_import {
	cse_alife_object::state_import(@_);
}
sub state_export {
	cse_alife_object::state_export(@_);
}
#######################################################################
package cse_alife_online_offline_group;
use strict;
use constant properties_info => (
	{ name => 'members', type => 'l32u16v', default => [] },
);
sub init {
	cse_alife_dynamic_object::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_dynamic_object::state_read(@_);
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	cse_alife_dynamic_object::state_write(@_);
	$_[1]->pack_properties($_[0], properties_info);
}
#######################################################################
package cse_alife_dynamic_object_visual;
use strict;
sub init {
	cse_alife_object::init(@_);
	cse_visual::init(@_);
}
sub state_read {
	cse_alife_object::state_read(@_);
	cse_visual::state_read(@_) if ($_[0]->{version} > 31);
}
sub state_write {
	cse_alife_object::state_write(@_);
	cse_visual::state_write(@_) if ($_[0]->{version} > 31);
}
sub state_import {
	cse_alife_object::state_import(@_);
	cse_visual::state_import(@_) if ($_[0]->{version} > 31);
}
sub state_export {
	cse_alife_object::state_export(@_);
	cse_visual::state_export(@_) if ($_[0]->{version} > 31);
}
#######################################################################
package cse_alife_object_climable;
use strict;
use constant properties_info => (
	{ name => 'game_material',	type => 'sz',	default => 'materials\\fake_ladders' },
);
sub init {
	cse_alife_object::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_object::state_read(@_) if ($_[0]->{version} > 99);
	cse_shape::state_read(@_);
	$_[1]->unpack_properties($_[0], properties_info) if ($_[0]->{version} >= 128);
}
sub state_write {
	cse_alife_object::state_write(@_) if ($_[0]->{version} > 99);
	cse_shape::state_write(@_);
	$_[1]->pack_properties($_[0], properties_info) if ($_[0]->{version} >= 128);
}
sub state_import {
	cse_alife_object::state_import(@_) if ($_[0]->{version} > 99);
	cse_shape::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info) if ($_[0]->{version} >= 128);
}
sub state_export {
	cse_alife_object::state_export(@_) if ($_[0]->{version} > 99);
	cse_shape::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info) if ($_[0]->{version} >= 128);
}
#######################################################################
package cse_alife_object_physic;
use strict;
use constant properties_info => (
	{ name => 'physic_type',	type => 'h32',	default => 0 },
	{ name => 'mass',		type => 'f32',	default => 0.0 },
	{ name => 'fixed_bones',	type => 'sz',	default => '' },
	{ name => 'startup_animation',	type => 'sz',	default => '' },
	{ name => 'skeleton_flags',		type => 'u8',	default => 0 },
	{ name => 'source_id',	type => 'u16',	default => 0 },
);
use constant upd_properties_info => (
	{ name => 'upd:num_items',	type => 'h8',	default => 0 },	
	{ name => 'upd:ph_force',		type => 'f32v3',	default => [0.0, 0.0, 0.0] },
	{ name => 'upd:ph_torque',		type => 'f32v3',	default => [0.0, 0.0, 0.0] },
	{ name => 'upd:ph_position',		type => 'f32v3',	default => [0.0, 0.0, 0.0] },
	{ name => 'upd:ph_rotation',		type => 'f32v4',	default => [0.0, 0.0, 0.0, 0.0] },
	{ name => 'upd:ph_angular_velosity',		type => 'f32v3',	default => [0.0, 0.0, 0.0] },
	{ name => 'upd:ph_linear_velosity',		type => 'f32v3',	default => [0.0, 0.0, 0.0] },
	{ name => 'upd:enabled',		type => 'u8', default => 1},
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	cse_ph_skeleton::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	if ($_[0]->{version} >= 14) {
		if ($_[0]->{version} < 16) {
			cse_alife_dynamic_object::state_read(@_);
		} else {
			cse_alife_dynamic_object_visual::state_read(@_);
		}
		if ($_[0]->{version} < 32) {
			cse_visual::state_read(@_);
		}
	}
	if ($_[0]->{version} >= 64) {
		cse_ph_skeleton::state_read(@_);
	}
	$_[1]->unpack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} > 9) {
		$_[1]->unpack_properties($_[0], (properties_info)[2]);
	}
	if (($_[0]->{version} > 28) && ($_[0]->{version} < 65)) {
		$_[1]->unpack_properties($_[0], (properties_info)[3]);
	}
	if ($_[0]->{version} < 64) {
		if ($_[0]->{version} > 39) {
			$_[1]->unpack_properties($_[0], (properties_info)[4]);
		}
		if ($_[0]->{version} > 56) {
			$_[1]->unpack_properties($_[0], (properties_info)[5]);
		}
	}
}
sub state_write {
	if ($_[0]->{version} >= 14) {
		if ($_[0]->{version} < 16) {
			cse_alife_dynamic_object::state_write(@_);
		} else {
			cse_alife_dynamic_object_visual::state_write(@_);
		}
		if ($_[0]->{version} < 32) {
			cse_visual::state_write(@_);
		}
	}
	if ($_[0]->{version} >= 64) {
		cse_ph_skeleton::state_write(@_);
	}
	$_[1]->pack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} > 9) {
		$_[1]->pack_properties($_[0], (properties_info)[2]);
	}
	if (($_[0]->{version} > 28) && ($_[0]->{version} < 65)) {
		$_[1]->pack_properties($_[0], (properties_info)[3]);
	}
	if ($_[0]->{version} < 64) {
		if ($_[0]->{version} > 39) {
			$_[1]->pack_properties($_[0], (properties_info)[4]);
		}
		if ($_[0]->{version} > 56) {
			$_[1]->pack_properties($_[0], (properties_info)[5]);
		}
	}
}
sub update_read {
	stkutils::entity::init_properties($_[0], upd_properties_info);
#	if ($_[1]->resid() != 0) {
		if (($_[0]->{version} >= 122) && ($_[0]->{version} <= 128)) {
			$_[1]->unpack_properties($_[0], (upd_properties_info)[0]);
			if ($_[0]->{'upd:num_items'} != 0) {
				$_[1]->unpack_properties($_[0], (upd_properties_info)[1..4]);
				my $flags = $_[0]->{'upd:num_items'} >> 5;
				if (($flags & 0x2) == 0) {
					$_[1]->unpack_properties($_[0], (upd_properties_info)[5]);
				}
				if (($flags & 0x4) == 0) {
					$_[1]->unpack_properties($_[0], (upd_properties_info)[6]);
				}
#				if ($_[1]->resid() != 0) {
					$_[1]->unpack_properties($_[0], (upd_properties_info)[7]);  #actually bool. Dunno how to make better yet.
#				}
			}
		}
#	}
}
sub update_import {
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
sub update_write {
		if (($_[0]->{version} >= 122) && ($_[0]->{version} <= 128)) {
			$_[1]->pack_properties($_[0], (upd_properties_info)[0]);
			if ($_[0]->{'upd:num_items'} != 0) {
				$_[1]->pack_properties($_[0], (upd_properties_info)[1..4]);
				my $flags = $_[0]->{'upd:num_items'} >> 5;
				if (($flags & 0x2) == 0) {
					$_[1]->pack_properties($_[0], (upd_properties_info)[5]);
				}
				if (($flags & 0x4) == 0) {
					$_[1]->pack_properties($_[0], (upd_properties_info)[6]);
				}
#				if (defined $_[0]->{'upd:enabled'}) {
#				if ($_[1]->resid() != 0) {
					$_[1]->pack_properties($_[0], (upd_properties_info)[7]);  #actually bool. Dunno how to make better yet.
#				}
			}
		}
}
sub state_import {
	if ($_[0]->{version} >= 14) {
		if ($_[0]->{version} < 16) {
			cse_alife_dynamic_object::state_import(@_);
		} else {
			cse_alife_dynamic_object_visual::state_import(@_);
		}
		if ($_[0]->{version} < 32) {
			cse_visual::state_import(@_);
		}
	}
	if ($_[0]->{version} >= 64) {
		cse_ph_skeleton::state_import(@_);
	}
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	if ($_[0]->{version} >= 14) {
		if ($_[0]->{version} < 16) {
			cse_alife_dynamic_object::state_export(@_);
		} else {
			cse_alife_dynamic_object_visual::state_export(@_);
		}
		if ($_[0]->{version} < 32) {
			cse_visual::state_export(@_);
		}
	}
	if ($_[0]->{version} >= 64) {
		cse_ph_skeleton::state_export(@_);
	}
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_object_hanging_lamp;
use strict;
use constant flPhysic		=> 0x0001;
use constant flCastShadow	=> 0x0002;
use constant flR1		=> 0x0004;
use constant flR2		=> 0x0008;
use constant flTypeSpot		=> 0x0010;
use constant flPointAmbient	=> 0x0020;
use constant properties_info => (
	{ name => 'main_color',		type => 'h32',	default => 0x00ffffff },
	{ name => 'main_brightness',	type => 'f32',	default => 0.0 },
	{ name => 'main_color_animator',type => 'sz',	default => '' },
	{ name => 'cse_alife_object_hanging_lamp__unk1_sz',type => 'sz',	default => '' },
	{ name => 'cse_alife_object_hanging_lamp__unk2_sz',type => 'sz',	default => '' },
	{ name => 'main_range',		type => 'f32',	default => 0.0 },
	{ name => 'light_flags',	type => 'h16',	default => 0 },
	{ name => 'cse_alife_object_hanging_lamp__unk3_f32',type => 'f32',	default => 0 },	
	{ name => 'animation',	type => 'sz',	default => '$editor' },
	{ name => 'cse_alife_object_hanging_lamp__unk4_sz',type => 'sz',	default => '' },
	{ name => 'cse_alife_object_hanging_lamp__unk5_f32',type => 'f32',	default => 0 },
	{ name => 'lamp_fixed_bones',	type => 'sz',	default => '' },
	{ name => 'health',		type => 'f32',	default => 1.0 },
	{ name => 'main_virtual_size',	type => 'f32',	default => 0.0 },
	{ name => 'ambient_radius',	type => 'f32',	default => 0.0 },
	{ name => 'ambient_power',	type => 'f32',	default => 0.0 },
	{ name => 'ambient_texture',	type => 'sz',	default => '' },
	{ name => 'main_texture',	type => 'sz',	default => '' },
	{ name => 'main_bone',		type => 'sz',	default => '' },
	{ name => 'main_cone_angle',	type => 'f32',	default => 0.0 },
	{ name => 'glow_texture',	type => 'sz',	default => '' },
	{ name => 'glow_radius',	type => 'f32',	default => 0.0 },
	{ name => 'ambient_bone',	type => 'sz',	default => '' },
	{ name => 'cse_alife_object_hanging_lamp__unk6_f32',type => 'f32',	default => 0.0 },
	{ name => 'cse_alife_object_hanging_lamp__unk7_f32',type => 'f32',	default => 0.0 },
	{ name => 'cse_alife_object_hanging_lamp__unk8_f32',type => 'f32',	default => 0.0 },
	{ name => 'main_cone_angle_old_format',	type => 'q8',	default => 0.0 },
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	cse_ph_skeleton::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	if ($_[0]->{version} > 20) {
		cse_alife_dynamic_object_visual::state_read(@_);
	}
	if ($_[0]->{version} >= 69) {
		cse_ph_skeleton::state_read(@_);
	}
	if ($_[0]->{version} < 32) {
		cse_visual::state_read(@_);
	}
	if ($_[0]->{version} < 49) {
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
		$_[1]->unpack_properties($_[0], (properties_info)[2..5]);
		$_[1]->unpack_properties($_[0], (properties_info)[26]);
		if ($_[0]->{version} > 10) {
			$_[1]->unpack_properties($_[0], (properties_info)[1]);
		}
		if ($_[0]->{version} > 11) {
			$_[1]->unpack_properties($_[0], (properties_info)[6]);
		}
		if ($_[0]->{version} > 12) {
			$_[1]->unpack_properties($_[0], (properties_info)[7]);
		}
		if ($_[0]->{version} > 17) {
			$_[1]->unpack_properties($_[0], (properties_info)[8]);
		}
		if ($_[0]->{version} > 42) {
			$_[1]->unpack_properties($_[0], (properties_info)[9..10]);
		}
		if ($_[0]->{version} > 43) {
			$_[1]->unpack_properties($_[0], (properties_info)[11]);
		}
		if ($_[0]->{version} > 44) {
			$_[1]->unpack_properties($_[0], (properties_info)[12]);
		}
	} else {
		$_[1]->unpack_properties($_[0], (properties_info)[0..2]);
		$_[1]->unpack_properties($_[0], (properties_info)[5..6]);
		$_[1]->unpack_properties($_[0], (properties_info)[8]);
		$_[1]->unpack_properties($_[0], (properties_info)[11..12]);
	}
	if ($_[0]->{version} > 55) {
		$_[1]->unpack_properties($_[0], (properties_info)[13..21]);
	}
	if ($_[0]->{version} > 96) {
		$_[1]->unpack_properties($_[0], (properties_info)[22]);
	}
	if ($_[0]->{version} > 118) {
		$_[1]->unpack_properties($_[0], (properties_info)[23..25]);
	}
}
sub state_write {
	if ($_[0]->{version} > 20) {
		cse_alife_dynamic_object_visual::state_write(@_);
	}
	if ($_[0]->{version} >= 69) {
		cse_ph_skeleton::state_write(@_);
	}
	if ($_[0]->{version} < 32) {
		cse_visual::state_write(@_);
	}
	if ($_[0]->{version} < 49) {
		$_[1]->pack_properties($_[0], (properties_info)[0]);
		$_[1]->pack_properties($_[0], (properties_info)[2..5]);
		$_[1]->pack_properties($_[0], (properties_info)[26]);
		if ($_[0]->{version} > 10) {
			$_[1]->pack_properties($_[0], (properties_info)[1]);
		}
		if ($_[0]->{version} > 11) {
			$_[1]->pack_properties($_[0], (properties_info)[6]);
		}
		if ($_[0]->{version} > 12) {
			$_[1]->pack_properties($_[0], (properties_info)[7]);
		}
		if ($_[0]->{version} > 17) {
			$_[1]->pack_properties($_[0], (properties_info)[8]);
		}
		if ($_[0]->{version} > 42) {
			$_[1]->pack_properties($_[0], (properties_info)[9..10]);
		}
		if ($_[0]->{version} > 43) {
			$_[1]->pack_properties($_[0], (properties_info)[11]);
		}
		if ($_[0]->{version} > 44) {
			$_[1]->pack_properties($_[0], (properties_info)[12]);
		}
	} else {
		$_[1]->pack_properties($_[0], (properties_info)[0..2]);
		$_[1]->pack_properties($_[0], (properties_info)[5..6]);
		$_[1]->pack_properties($_[0], (properties_info)[8]);
		$_[1]->pack_properties($_[0], (properties_info)[11..12]);
	}
	if ($_[0]->{version} > 55) {
		$_[1]->pack_properties($_[0], (properties_info)[13..21]);
	}
	if ($_[0]->{version} > 96) {
		$_[1]->pack_properties($_[0], (properties_info)[22]);
	}
	if ($_[0]->{version} > 118) {
		$_[1]->pack_properties($_[0], (properties_info)[23..25]);
	}
}
sub state_import {
	if ($_[0]->{version} > 20) {
		cse_alife_dynamic_object_visual::state_import(@_);
	}
	if ($_[0]->{version} >= 69) {
		cse_ph_skeleton::state_import(@_);
	}
	if ($_[0]->{version} < 32) {
		cse_visual::state_import(@_);
	}
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	if ($_[0]->{version} > 20) {
		cse_alife_dynamic_object_visual::state_export(@_);
	}
	if ($_[0]->{version} >= 69) {
		cse_ph_skeleton::state_export(@_);
	}
	if ($_[0]->{version} < 32) {
		cse_visual::state_export(@_);
	}
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_object_projector;
use strict;
use constant properties_info => (
	{ name => 'main_color',		type => 'h32',	default => 0x00ffffff },
	{ name => 'main_color_animator',type => 'sz',	default => '' },
	{ name => 'animation',	type => 'sz',	default => '$editor' },
	{ name => 'ambient_radius',	type => 'f32',	default => 0.0 },
	{ name => 'main_cone_angle',	type => 'q8',	default => 0.0 },
	{ name => 'main_virtual_size',	type => 'f32',	default => 0.0 },
	{ name => 'glow_texture',	type => 'sz',	default => '' },
	{ name => 'glow_radius',	type => 'f32',	default => 0.0 },
	{ name => 'cse_alife_object_hanging_lamp__unk3_u8',	type => 'u16',	default => 0 },
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
	if ($_[0]->{version} < 48) {
		$_[1]->unpack_properties($_[0], (properties_info)[0..5]);
		if ($_[0]->{version} > 40) {
			$_[1]->unpack_properties($_[0], (properties_info)[6..7]);
		}
		if ($_[0]->{version} > 45) {
			$_[1]->unpack_properties($_[0], (properties_info)[8]);
		}
	}
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
	if ($_[0]->{version} < 48) {
		$_[1]->pack_properties($_[0], (properties_info)[0..5]);
		if ($_[0]->{version} > 40) {
			$_[1]->pack_properties($_[0], (properties_info)[6..7]);
		}
		if ($_[0]->{version} > 45) {
			$_[1]->pack_properties($_[0], (properties_info)[8]);
		}
	}
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_inventory_box;
use strict;
use constant properties_info => (
	{ name => 'cse_alive_inventory_box__unk1_u8', type => 'u8', default => 1 },
	{ name => 'cse_alive_inventory_box__unk2_u8', type => 'u8', default => 0 },
	{ name => 'tip', type => 'sz', default => '' },
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
	if ($_[0]->{version} >= 128) {
		$_[1]->unpack_properties($_[0], properties_info);
	}
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
	if ($_[0]->{version} >= 128) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
	if ($_[0]->{version} >= 128) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
	if ($_[0]->{version} >= 128) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
#######################################################################
package cse_alife_object_breakable;
use strict;
use constant properties_info => (
	{ name => 'health', type => 'f32', default => 1.0 },
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_mounted_weapon;
use strict;
sub init {
	cse_alife_dynamic_object_visual::init(@_);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
}
#######################################################################
package cse_alife_stationary_mgun;
use strict;
use constant upd_properties_info => (
	{ name => 'upd:working',		type => 'u8', default => 0},
	{ name => 'upd:dest_enemy_direction',	type => 'f32v3', default => [0.0, 0.0, 0.0]},
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
}
sub update_read {
	$_[1]->unpack_properties($_[0], upd_properties_info);
}
sub update_write {
	$_[1]->pack_properties($_[0], upd_properties_info);
}
sub update_import {
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package cse_alife_ph_skeleton_object;
use strict;
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	cse_ph_skeleton::init(@_);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
	if ($_[0]->{version} >= 64) {
		cse_ph_skeleton::state_read(@_);
	}
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
	if ($_[0]->{version} >= 64) {
		cse_ph_skeleton::state_write(@_);
	}
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
	if ($_[0]->{version} >= 64) {
		cse_ph_skeleton::state_import(@_);
	}
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
	if ($_[0]->{version} >= 64) {
		cse_ph_skeleton::state_export(@_);
	}
}
#######################################################################
package cse_alife_car;
use strict;
use constant properties_info => (
	{ name => 'cse_alife_car__unk1_f32', type => 'f32', default => 1.0 },	
	{ name => 'health', type => 'f32', default => 1.0 },	
	{ name => 'g_team', type => 'u8', default => 0 },	
	{ name => 'g_squad', type => 'u8', default => 0 },	
	{ name => 'g_group', type => 'u8', default => 0 },		
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	cse_ph_skeleton::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	if (($_[0]->{version} < 8) || ($_[0]->{version} > 16)) {
		cse_alife_dynamic_object_visual::state_read(@_);
	}
	if ($_[0]->{version} < 8) {
		$_[1]->unpack_properties($_[0], (properties_info)[2..4]);
	}
	if ($_[0]->{version} > 65) {
		cse_ph_skeleton::state_read(@_);
	}
	if (($_[0]->{version} > 52) && (($_[0]->{version} < 55))) {
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
	}
	if ($_[0]->{version} > 92) {
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
	}
#	if ($_[0]->{health} > 1.0) {
#		$_[0]->{health} *= 0.01;
#	}
}
sub state_write {
	if (($_[0]->{version} < 8) || ($_[0]->{version} > 16)) {
		cse_alife_dynamic_object_visual::state_write(@_);
	}
	if ($_[0]->{version} < 8) {
	$_[1]->pack_properties($_[0], (properties_info)[2..4]);
	}
	if ($_[0]->{version} > 65) {
		cse_ph_skeleton::state_write(@_);
	}
	if (($_[0]->{version} > 52) && (($_[0]->{version} < 55))) {
		$_[1]->pack_properties($_[0], (properties_info)[0]);
	}
	if ($_[0]->{version} > 92) {
		$_[1]->pack_properties($_[0], (properties_info)[1]);
	}
#	if ($_[0]->{health} > 1.0) {
#		$_[0]->{health} *= 0.01;
#	}
}
sub state_import {
	if (($_[0]->{version} < 8) || ($_[0]->{version} > 16)) {
		cse_alife_dynamic_object_visual::state_import(@_);
	}
	if ($_[0]->{version} > 65) {
		cse_ph_skeleton::state_import(@_);
	}
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	if (($_[0]->{version} < 8) || ($_[0]->{version} > 16)) {
		cse_alife_dynamic_object_visual::state_export(@_);
	}
	if ($_[0]->{version} > 65) {
		cse_ph_skeleton::state_export(@_);
	}
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_helicopter;
use strict;
use constant properties_info => (
	{ name => 'cse_alife_helicopter__unk1_sz',	type => 'sz', default => '' },
	{ name => 'engine_sound',			type => 'sz', default => '' },
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	cse_ph_skeleton::init(@_);
	cse_motion::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
	cse_motion::state_read(@_);
	if ($_[0]->{version} >= 69) {
		cse_ph_skeleton::state_read(@_);
	}
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
	cse_motion::state_write(@_);
	if ($_[0]->{version} >= 69) {
		cse_ph_skeleton::state_write(@_);
	}
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
	cse_motion::state_import(@_);
	if ($_[0]->{version} >= 69) {
		cse_ph_skeleton::state_import(@_);
	}
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
	cse_motion::state_export(@_);
	if ($_[0]->{version} >= 69) {
		cse_ph_skeleton::state_export(@_);
	}
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_creature_abstract;
use strict;
use constant FL_IS_25XX => 0x08;
use constant properties_info => (
	{ name => 'g_team',			type => 'u8',	default => 0xff },
	{ name => 'g_squad',			type => 'u8',	default => 0xff },
	{ name => 'g_group',			type => 'u8',	default => 0xff },
	{ name => 'health',			type => 'f32',	default => 1.0 },
	{ name => 'dynamic_out_restrictions',	type => 'l32u16v', default => [0] },
	{ name => 'dynamic_in_restrictions',	type => 'l32u16v', default => [0] },
	{ name => 'killer_id',			type => 'h16', default => 0xffff },
	{ name => 'game_death_time',		type => 'u8v8', default => [0,0,0,0,0,0,0,0] },
);
use constant upd_properties_info => (
	{ name => 'upd:health',		type => 'f32',	default => -1  },
	{ name => 'upd:timestamp',	type => 'h32',	default => 0xFFFF  },
	{ name => 'upd:creature_flags',	type => 'h8',	default => 0xFF  },	
	{ name => 'upd:position',	type => 'f32v3',	default => []  },
	{ name => 'upd:o_model',	type => 'f32',	default => 0  },
	{ name => 'upd:o_torso',	type => 'f32v3',	default => [0.0, 0.0, 0.0]  },
	{ name => 'upd:o_model_pkd',	type => 'q8',	default => 0  },
	{ name => 'upd:o_torso_pkd',	type => 'q8v3',	default => [0,0,0]  },
	{ name => 'upd:g_team',		type => 'u8',	default => 0  },	
	{ name => 'upd:g_squad',	type => 'u8',	default => 0  },	
	{ name => 'upd:g_group',	type => 'u8',	default => 0  },
	{ name => 'upd:health_pkd',		type => 'q16',	default => 0  },
	{ name => 'upd:health_pkd_old',		type => 'q16_old',	default => 0  },
	{ name => 'upd:cse_alife_creature_abstract__unk1_f32v3',		type => 'f32v3', default => [0.0, 0.0, 0.0]},
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
	$_[1]->unpack_properties($_[0], (properties_info)[0..2]);
	if ($_[0]->{version} > 18) {
		$_[1]->unpack_properties($_[0], (properties_info)[3]);
	}
	if ($_[0]->{version} < 32) {
		cse_visual::state_read(@_);
	}	
	if ($_[0]->{version} > 87) {
		$_[1]->unpack_properties($_[0], (properties_info)[4..5]);
	}
	if ($_[0]->{version} > 94) {
		$_[1]->unpack_properties($_[0], (properties_info)[6]);
	}
	if ($_[0]->{version} > 115) {
		$_[1]->unpack_properties($_[0], (properties_info)[7]);
	}
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
	$_[1]->pack_properties($_[0], (properties_info)[0..2]);
	if ($_[0]->{version} > 18) {
		$_[1]->pack_properties($_[0], (properties_info)[3]);
	}
	if ($_[0]->{version} < 32) {
		cse_visual::state_write(@_);
	}	
	if ($_[0]->{version} > 87) {
		$_[1]->pack_properties($_[0], (properties_info)[4..5]);
	}
	if ($_[0]->{version} > 94) {
		$_[1]->pack_properties($_[0], (properties_info)[6]);
	}
	if ($_[0]->{version} > 115) {
		$_[1]->pack_properties($_[0], (properties_info)[7]);
	}
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
	if ($_[0]->{version} < 32) {
		cse_visual::state_import(@_);
	}	
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
	if ($_[0]->{version} < 32) {
		cse_visual::state_export(@_);
	}	
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	if ($_[0]->{version} > 109) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[0]);
	} elsif ($_[0]->{version} > 40) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[11]);
	} else {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[12]);
	}
	if (($_[0]->{version} < 17) && (ref($_[0]) eq 'se_actor')) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[13]);
	}
	$_[1]->unpack_properties($_[0], (upd_properties_info)[1..3]);
	if (($_[0]->{version} > 117) && (!is_2588($_[0]))) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[4..5]);
	} else {
		if ($_[0]->{version} > 85) {
			$_[1]->unpack_properties($_[0], (upd_properties_info)[6]);
		}
		if ($_[0]->{version} > 63) {
			$_[1]->unpack_properties($_[0], (upd_properties_info)[7]);
		}
	}
	$_[1]->unpack_properties($_[0], (upd_properties_info)[8..10]);
}
sub update_write {
	if ($_[0]->{version} > 109) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[0]);
	} elsif ($_[0]->{version} > 40) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[11]);
	} else {
		$_[1]->pack_properties($_[0], (upd_properties_info)[12]);
	}
	if (($_[0]->{version} < 17) && (ref($_[0]) eq 'se_actor')) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[13]);
	}
	$_[1]->pack_properties($_[0], (upd_properties_info)[1..3]);
	if (($_[0]->{version} > 117) && (!is_2588($_[0]))) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[4..5]);
	} else {
		if ($_[0]->{version} > 85) {
			$_[1]->pack_properties($_[0], (upd_properties_info)[6]);
		}
		if ($_[0]->{version} > 63) {
			$_[1]->pack_properties($_[0], (upd_properties_info)[7]);
		}
	}
	$_[1]->pack_properties($_[0], (upd_properties_info)[8..10]);
}
sub update_import {
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
sub is_2588 {return ($_[0]->{flags} & FL_IS_25XX)}
#######################################################################
package cse_alife_creature_crow;
use strict;
sub init {
	cse_alife_creature_abstract::init(@_);
	cse_visual::init(@_);
}
sub state_read {
	if ($_[0]->{version} > 20) {
		cse_alife_creature_abstract::state_read(@_);
		if ($_[0]->{version} < 32) {
			cse_visual::state_read(@_);
		}
	}
}
sub state_write {
	if ($_[0]->{version} > 20) {
		cse_alife_creature_abstract::state_write(@_);
		if ($_[0]->{version} < 32) {
			cse_visual::state_write(@_);
		}
	}
}
sub state_import {
	if ($_[0]->{version} > 20) {
		cse_alife_creature_abstract::state_import(@_);
		if ($_[0]->{version} < 32) {
			cse_visual::state_import(@_);
		}
	}
}
sub state_export {
	if ($_[0]->{version} > 20) {
		cse_alife_creature_abstract::state_export(@_);
		if ($_[0]->{version} < 32) {
			cse_visual::state_export(@_);
		}
	}
}
sub update_read {
	cse_alife_creature_abstract::update_read(@_);
}
sub update_write {
	cse_alife_creature_abstract::update_write(@_);
}
sub update_import {
	cse_alife_creature_abstract::update_import(@_);
}
sub update_export {
	cse_alife_creature_abstract::update_export(@_);
}
#######################################################################
package cse_alife_creature_phantom;
use strict;
sub init {
	cse_alife_creature_abstract::init(@_);
}
sub state_read {
	cse_alife_creature_abstract::state_read(@_);
}
sub state_write {
	cse_alife_creature_abstract::state_write(@_);
}
sub state_import {
	cse_alife_creature_abstract::state_import(@_);
}
sub state_export {
	cse_alife_creature_abstract::state_export(@_);
}
sub update_read {
	cse_alife_creature_abstract::update_read(@_);
}
sub update_write {
	cse_alife_creature_abstract::update_write(@_);
}
sub update_import {
	cse_alife_creature_abstract::update_import(@_);
}
sub update_export {
	cse_alife_creature_abstract::update_export(@_);
}
#######################################################################
package cse_alife_monster_abstract;
use strict;
use constant properties_info => (
	{ name => 'base_out_restrictors',	type => 'sz',	default => '' },
	{ name => 'base_in_restrictors',	type => 'sz',	default => '' },
	{ name => 'smart_terrain_id',		type => 'u16',	default => 65535 },
	{ name => 'smart_terrain_task_active',	type => 'u8',	default => 0 },
);
use constant upd_properties_info => (
	{ name => 'upd:next_game_vertex_id',	type => 'u16',	default => 0xFFFF },
	{ name => 'upd:prev_game_vertex_id',	type => 'u16',	default => 0xFFFF },
	{ name => 'upd:distance_from_point',	type => 'f32',	default => 0 },
	{ name => 'upd:distance_to_point',	type => 'f32',	default => 0 },
	{ name => 'upd:cse_alife_monster_abstract__unk1_u32',	type => 'u32',	default => 0 },
	{ name => 'upd:cse_alife_monster_abstract__unk2_u32',	type => 'u32',	default => 0 },
);
sub init {
	cse_alife_creature_abstract::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_creature_abstract::state_read(@_);
	if ($_[0]->{version} > 72) {
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
	}
	if ($_[0]->{version} > 73) {
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
	}
	if ($_[0]->{version} > 111) {
		$_[1]->unpack_properties($_[0], (properties_info)[2]);
	}	
	if ($_[0]->{version} > 113) {
		$_[1]->unpack_properties($_[0], (properties_info)[3]);
	}
}
sub state_write {
	cse_alife_creature_abstract::state_write(@_);
	if ($_[0]->{version} > 72) {
		$_[1]->pack_properties($_[0], (properties_info)[0]);
	}
	if ($_[0]->{version} > 73) {
		$_[1]->pack_properties($_[0], (properties_info)[1]);
	}
	if ($_[0]->{version} > 111) {
		$_[1]->pack_properties($_[0], (properties_info)[2]);
	}	
	if ($_[0]->{version} > 113) {
		$_[1]->pack_properties($_[0], (properties_info)[3]);
	}
}
sub state_import {
	cse_alife_creature_abstract::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_creature_abstract::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_creature_abstract::update_read(@_);
	$_[1]->unpack_properties($_[0], (upd_properties_info)[0..3]);
	if ($_[0]->{version} <= 79) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[4..5]);
	}
}
sub update_write {
	cse_alife_creature_abstract::update_write(@_);
	$_[1]->pack_properties($_[0], (upd_properties_info)[0..3]);
	if ($_[0]->{version} <= 79) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[4..5]);
	}
}
sub update_import {
	cse_alife_creature_abstract::update_import(@_);
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	cse_alife_creature_abstract::update_export(@_);
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package cse_alife_psy_dog_phantom;
use strict;
sub init {
	cse_alife_monster_base::init(@_);
}
sub state_read {
	cse_alife_monster_base::state_read(@_);
}
sub state_write {
	cse_alife_monster_base::state_write(@_);
}
sub state_import {
	cse_alife_monster_base::state_import(@_);
}
sub state_export {
	cse_alife_monster_base::state_export(@_);
}
sub update_read {
	cse_alife_monster_base::update_read(@_);
}
sub update_write {
	cse_alife_monster_base::update_write(@_);
}
sub update_import {
	cse_alife_monster_base::update_import(@_);
}
sub update_export {
	cse_alife_monster_base::update_export(@_);
}
#######################################################################
package cse_alife_monster_rat;
use strict;
use constant properties_info => (
	{ name => 'field_of_view',			type => 'f32', default => 120.0 },
	{ name => 'eye_range',				type => 'f32', default => 10.0 },
	{ name => 'minimum_speed',			type => 'f32', default => 0.5 },
	{ name => 'maximum_speed',			type => 'f32', default => 1.5 },
	{ name => 'attack_speed',			type => 'f32', default => 4.0 },
	{ name => 'pursiut_distance',		type => 'f32', default => 100.0 },
	{ name => 'home_distance',			type => 'f32', default => 10.0 },
	{ name => 'success_attack_quant',	type => 'f32', default => 20.0 },
	{ name => 'death_quant',			type => 'f32', default => -10.0 },
	{ name => 'fear_quant',				type => 'f32', default => -20.0 },
	{ name => 'restore_quant',			type => 'f32', default => 10.0 },
	{ name => 'restore_time_interval',	type => 'u16', default => 3000 },
	{ name => 'minimum_value',			type => 'f32', default => 0.0 },
	{ name => 'maximum_value',			type => 'f32', default => 100.0 },
	{ name => 'normal_value',			type => 'f32', default => 66.0 },
	{ name => 'hit_power',				type => 'f32', default => 10.0 },
	{ name => 'hit_interval',			type => 'u16', default => 1500 },
	{ name => 'distance',				type => 'f32', default => 0.7 },
	{ name => 'maximum_angle',			type => 'f32', default => 45.0 },
	{ name => 'success_probability',	type => 'f32', default => 0.5 },
	{ name => 'cse_alife_monster_rat__unk1_f32',	type => 'f32', default => 5.0 },
);
sub init {
	cse_alife_monster_abstract::init(@_);
	cse_alife_inventory_item::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_monster_abstract::state_read(@_);
	$_[1]->unpack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} < 7) {
		$_[1]->unpack_properties($_[0], (properties_info)[20]);
	}
	$_[1]->unpack_properties($_[0], (properties_info)[2..19]);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::state_read(@_);
	}
}
sub state_write {
	cse_alife_monster_abstract::state_write(@_);
	$_[1]->pack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} < 7) {
		$_[1]->pack_properties($_[0], (properties_info)[20]);
	}
	$_[1]->pack_properties($_[0], (properties_info)[2..19]);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::state_write(@_);
	}
}
sub state_import {
	cse_alife_monster_abstract::state_import(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::state_import(@_);
	}
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_monster_abstract::state_export(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::state_export(@_);
	}
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_monster_abstract::update_read(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::update_read(@_);
	}
}
sub update_write {
	cse_alife_monster_abstract::update_write(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::update_write(@_);
	}
}
sub update_import {
	cse_alife_monster_abstract::update_import(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::update_import(@_);
	}
}
sub update_export {
	cse_alife_monster_abstract::update_export(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::update_export(@_);
	}
}
#######################################################################
package cse_alife_rat_group; 
use strict;
use constant properties_info => (
	{ name => 'cse_alife_rat_group__unk_1_u32',		type => 'u32', default => 1 },
	{ name => 'alife_count',						type => 'u16', default => 5 },
	{ name => 'cse_alife_rat_group__unk_2_l32u16v',	type => 'l32u16v', default => [0] },
);
use constant upd_properties_info => (
	{ name => 'upd:alife_count',		type => 'u32', default => 1 },
);
sub init {
	cse_alife_monster_rat::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_monster_rat::state_read(@_);
	$_[1]->unpack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} > 16) {
		$_[1]->unpack_properties($_[0], (properties_info)[2]);
	}
}
sub state_write {
	cse_alife_monster_rat::state_write(@_);
	$_[1]->pack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} > 16) {
		$_[1]->pack_properties($_[0], (properties_info)[2]);
	}
}
sub state_import {
	cse_alife_monster_rat::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_monster_rat::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_monster_rat::update_read(@_);
	$_[1]->unpack_properties($_[0], upd_properties_info);	
}
sub update_write {
	cse_alife_monster_rat::update_write(@_);
	$_[1]->pack_properties( $_[0], upd_properties_info);	
}
sub update_import {
	cse_alife_monster_rat::update_import(@_);
	$_[1]->import_properties($_[2], $_[0],upd_properties_info);	
}
sub update_export {
	cse_alife_monster_rat::update_export(@_);
	$_[1]->export_properties(undef, $_[0], upd_properties_info);	
}
#######################################################################
package cse_alife_monster_base;
use strict;
use constant properties_info => (
	{ name => 'spec_object_id', type => 'u16', default => 65535 },
);
sub init {
	cse_alife_monster_abstract::init(@_);
	cse_ph_skeleton::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_monster_abstract::state_read(@_);
	if ($_[0]->{version} >= 68) {
		cse_ph_skeleton::state_read(@_);
	}
	if ($_[0]->{version} >= 109) {
		$_[1]->unpack_properties($_[0], properties_info);
	}
}
sub state_write {
	cse_alife_monster_abstract::state_write(@_);
	if ($_[0]->{version} >= 68) {
		cse_ph_skeleton::state_write(@_);
	}
	if ($_[0]->{version} >= 109) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_monster_abstract::state_import(@_);
	if ($_[0]->{version} >= 68) {
		cse_ph_skeleton::state_import(@_);
	}
	if ($_[0]->{version} >= 109) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_monster_abstract::state_export(@_);
	if ($_[0]->{version} >= 68) {
		cse_ph_skeleton::state_export(@_);
	}
	if ($_[0]->{version} >= 109) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
sub update_read {
	cse_alife_monster_abstract::update_read(@_);
}
sub update_write {
	cse_alife_monster_abstract::update_write(@_);
}
sub update_import {
	cse_alife_monster_abstract::update_import(@_);
}
sub update_export {
	cse_alife_monster_abstract::update_export(@_);
}
#######################################################################
package cse_alife_monster_zombie;
use strict;
use constant properties_info => (
	{ name => 'field_of_view',	type => 'f32',	default => 0.0 },
	{ name => 'eye_range',		type => 'f32',	default => 0.0 },
	{ name => 'health',	type => 'f32',	default => 1.0 },
	{ name => 'minimum_speed',	type => 'f32',	default => 0.0 },
	{ name => 'maximum_speed',	type => 'f32',	default => 0.0 },
	{ name => 'attack_speed',	type => 'f32',	default => 0.0 },
	{ name => 'pursuit_distance',	type => 'f32',	default => 0.0 },
	{ name => 'home_distance',	type => 'f32',	default => 0.0 },
	{ name => 'hit_power',		type => 'f32',	default => 0.0 },
	{ name => 'hit_interval',	type => 'u16',	default => 0 },	
	{ name => 'distance',		type => 'f32',	default => 0.0 },
	{ name => 'maximum_angle',	type => 'f32',	default => 0.0 },
);
sub init {
	cse_alife_monster_abstract::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_monster_abstract::state_read(@_);
	$_[1]->unpack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} <= 5) {
		$_[1]->unpack_properties($_[0], (properties_info)[2]);
	}
	$_[1]->unpack_properties($_[0], (properties_info)[3..11]);
}
sub state_write {
	cse_alife_monster_abstract::state_write(@_);
	$_[1]->pack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} <= 5) {
		$_[1]->pack_properties($_[0], (properties_info)[2]);
	}
	$_[1]->pack_properties($_[0], (properties_info)[3..11]);
}
sub state_import {
	cse_alife_monster_abstract::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_monster_abstract::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_monster_abstract::update_read(@_);
}
sub update_write {
	cse_alife_monster_abstract::update_write(@_);
}
sub update_import {
	cse_alife_monster_abstract::update_import(@_);
}
sub update_export {
	cse_alife_monster_abstract::update_export(@_);
}
#######################################################################
package cse_alife_flesh_group;
use strict;
use constant properties_info => (
	{ name => 'cse_alife_flash_group__unk_1_u32',		type => 'u32', default => 0 },
	{ name => 'alife_count',						type => 'u16', default => 0 },
	{ name => 'cse_alife_flash_group__unk_2_l32u16v',	type => 'l32u16v', default => [0] },
);
use constant upd_properties_info => (
	{ name => 'upd:alife_count',	type => 'u32', default => 1 },
);
sub init {
	cse_alife_monster_base::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_monster_base::state_read(@_);
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	cse_alife_monster_base::state_write(@_);
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	cse_alife_monster_base::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_monster_base::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_monster_base::update_read(@_);
	$_[1]->unpack_properties($_[0], upd_properties_info);
}
sub update_write {
	cse_alife_monster_base::update_write(@_);
	$_[1]->pack_properties($_[0], upd_properties_info);
}
sub update_import {
	cse_alife_monster_base::update_import(@_);
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	cse_alife_monster_base::update_export(@_);
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package cse_alife_trader_abstract;
use strict;
use constant eTraderFlagInfiniteAmmo	=> 0x00000001;
use constant eTraderFlagDummy		=> 0x00000000;	# really???
use constant properties_info => (
	{ name => 'cse_alife_trader_abstract__unk1_u32',	type => 'u32',	default => 0 },
	{ name => 'money',		type => 'u32',	default => 0 },
	{ name => 'specific_character',	type => 'sz',	default => '' },
	{ name => 'trader_flags',	type => 'h32',	default => 0x1 },
	{ name => 'character_profile',	type => 'sz',	default => '' },
	{ name => 'community_index',	type => 'h32',	default => 0xffffffff },
	{ name => 'rank',		type => 'h32',	default => 0x80000001 },
	{ name => 'reputation',		type => 'h32',	default => 0x80000001 },
	{ name => 'checked_characters',	type => 'sz',	default => '' },
	{ name => 'cse_alife_trader_abstract__unk2_u8',	type => 'u8',	default => 0 },
	{ name => 'cse_alife_trader_abstract__unk3_u8',	type => 'u8',	default => 0 },
	{ name => 'cse_alife_trader_abstract__unk4_u32',	type => 'u32',	default => 0 },
	{ name => 'cse_alife_trader_abstract__unk5_u32',	type => 'u32',	default => 0 },
	{ name => 'cse_alife_trader_abstract__unk6_u32',	type => 'u32',	default => 0 },
);
use constant upd_properties_info => (
	{ name => 'upd:cse_alife_trader_abstract__unk1_u32',	type => 'u32',	default => 0 },
	{ name => 'upd:money',		type => 'u32',	default => 0 },
	{ name => 'upd:cse_trader_abstract__unk2_u32',	type => 'u32',	default => 1 },
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	if ($_[0]->{version} > 19) {
		if ($_[0]->{version} < 108) {
			$_[1]->unpack_properties($_[0], (properties_info)[0]);
		}
		if ($_[0]->{version} < 36) {
			$_[1]->unpack_properties($_[0], (properties_info)[13]);
		}
		if ($_[0]->{version} > 62) {
			$_[1]->unpack_properties($_[0], (properties_info)[1]);
		}
		if ($_[0]->{version} > 94) {
			$_[1]->unpack_properties($_[0], (properties_info)[2]);
		}
		if (($_[0]->{version} > 75) && ($_[0]->{version} < 95)) {
			$_[1]->unpack_properties($_[0], (properties_info)[11]);
			if ($_[0]->{version} > 79) {
				$_[1]->unpack_properties($_[0], (properties_info)[12]);
			}
		}
		if ($_[0]->{version} > 77) {
			$_[1]->unpack_properties($_[0], (properties_info)[3]);
		}
		if ($_[0]->{version} > 95) {
			$_[1]->unpack_properties($_[0], (properties_info)[4]);
		}
		if ($_[0]->{version} > 85) {
			$_[1]->unpack_properties($_[0], (properties_info)[5]);
		}
		if ($_[0]->{version} > 86) {
			$_[1]->unpack_properties($_[0], (properties_info)[6..7]);
		}
		if ($_[0]->{version} > 104) {
			$_[1]->unpack_properties($_[0], (properties_info)[8]);
		}
		if ($_[0]->{version} >= 128) {
			$_[1]->unpack_properties($_[0], (properties_info)[9..10]);
		}
	}
}
sub state_write {
	if ($_[0]->{version} > 19) {
		if ($_[0]->{version} < 108) {
			$_[1]->pack_properties($_[0], (properties_info)[0]);
		}
		if ($_[0]->{version} < 36) {
			$_[1]->pack_properties($_[0], (properties_info)[13]);
		}
		if ($_[0]->{version} > 62) {
			$_[1]->pack_properties($_[0], (properties_info)[1]);
		}
		if ($_[0]->{version} > 94) {
			$_[1]->pack_properties($_[0], (properties_info)[2]);
		}
		if (($_[0]->{version} > 75) && ($_[0]->{version} < 95)) {
			$_[1]->pack_properties($_[0], (properties_info)[11]);
			if ($_[0]->{version} > 79) {
				$_[1]->pack_properties($_[0], (properties_info)[12]);
			}
		}
		if ($_[0]->{version} > 77) {
			$_[1]->pack_properties($_[0], (properties_info)[3]);
		}
		if ($_[0]->{version} > 95) {
			$_[1]->pack_properties($_[0], (properties_info)[4]);
		}
		if ($_[0]->{version} > 85) {
			$_[1]->pack_properties($_[0], (properties_info)[5]);
		}
		if ($_[0]->{version} > 86) {
			$_[1]->pack_properties($_[0], (properties_info)[6..7]);
		}
		if ($_[0]->{version} > 104) {
			$_[1]->pack_properties($_[0], (properties_info)[8]);
		}
		if ($_[0]->{version} >= 128) {
			$_[1]->pack_properties($_[0], (properties_info)[9..10]);
		}
	}
}
sub state_import {	
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	if (($_[0]->{version} > 19) && ($_[0]->{version} < 102)) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[0..1]);
		if ($_[0]->{version} < 86) {
			$_[1]->unpack_properties($_[0], (upd_properties_info)[2]);
		}
	}
}
sub update_write {
	if (($_[0]->{version} > 19) && ($_[0]->{version} < 102)) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[0..1]);
		if ($_[0]->{version} < 86) {
			$_[1]->pack_properties($_[0], (upd_properties_info)[2]);
		}
	}
}
sub update_import {	
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {	
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package cse_alife_trader;
use strict;
use constant properties_info => (
	{ name => 'organization_id',			type => 'u32',	default => 1 },
	{ name => 'ordered_artefacts',	type => 'ordaf',	default => ['none'] },
	{ name => 'supplies',		type => 'supplies',	default => ['none'] },
);
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	cse_alife_trader_abstract::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
	cse_alife_trader_abstract::state_read(@_);
	if ($_[0]->{version} < 118) {
		if ($_[0]->{version} > 35) {
			$_[1]->unpack_properties($_[0], (properties_info)[0]);
		}
		if ($_[0]->{version} > 29) {
			$_[1]->unpack_properties($_[0], (properties_info)[1]);
		}
		if ($_[0]->{version} > 30) {
			$_[1]->unpack_properties($_[0], (properties_info)[2]);
		}
	}
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
	cse_alife_trader_abstract::state_write(@_);
	if ($_[0]->{version} < 118) {
		if ($_[0]->{version} > 35) {
			$_[1]->pack_properties($_[0], (properties_info)[0]);
		}
		if ($_[0]->{version} > 29) {
			$_[1]->pack_properties($_[0], (properties_info)[1]);
		}
		if ($_[0]->{version} > 30) {
			$_[1]->pack_properties($_[0], (properties_info)[2]);
		}
	}
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
	cse_alife_trader_abstract::state_import(@_);
	if ($_[0]->{version} < 118) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
	cse_alife_trader_abstract::state_export(@_);
	if ($_[0]->{version} < 118) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
sub update_read {
	cse_alife_trader_abstract::update_read(@_);
}
sub update_write {
	cse_alife_trader_abstract::update_write(@_);
}
sub update_import {
	cse_alife_trader_abstract::update_import(@_);
}
sub update_export {
	cse_alife_trader_abstract::update_export(@_);
}
#######################################################################
package cse_alife_human_abstract;
use strict;
use constant properties_info => (
	{ name => 'path',	type => 'l32u32v',	default => [0] },
	{ name => 'visited_vertices',	type => 'u32', 		default => 0 },
	{ name => 'known_customers_sz',		type => 'sz', default => '' },
	{ name => 'known_customers',	type => 'l32u32v', default => [0] },
	{ name => 'equipment_preferences',	type => 'l32u8v', default => [0] },
	{ name => 'main_weapon_preferences',	type => 'l32u8v', default => [0] },
	{ name => 'smart_terrain_id',	type => 'u16', default => 0 },
	{ name => 'cse_alife_human_abstract__unk1_u32',	type => 'ha1', 		default => [0] },
	{ name => 'cse_alife_human_abstract__unk2_u32',	type => 'ha2', 		default => [0] },
	{ name => 'cse_alife_human_abstract__unk3_u32',	type => 'u32', 		default => 0 },
);
use constant upd_properties_info => (
	{ name => 'upd:cse_alife_human_abstract__unk3_u32',	type => 'u32', 		default => 0 },
	{ name => 'upd:cse_alife_human_abstract__unk4_u32',	type => 'u32', 		default => 0xffffffff },
	{ name => 'upd:cse_alife_human_abstract__unk5_u32',	type => 'u32', 		default => 0xffffffff },
);
sub init {
	cse_alife_monster_abstract::init(@_);
	cse_alife_trader_abstract::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_trader_abstract::state_read(@_);
	cse_alife_monster_abstract::state_read(@_);
	if ($_[0]->{version} > 19) {
		if ($_[0]->{version} < 110) {
			$_[1]->unpack_properties($_[0], (properties_info)[0..1]);
		}
		if ($_[0]->{version} > 35) {
			if ($_[0]->{version} < 110) {
				$_[1]->unpack_properties($_[0], (properties_info)[2]);
			}
			if ($_[0]->{version} < 118) {
				$_[1]->unpack_properties($_[0], (properties_info)[3]);
			}
		} else {
			$_[1]->unpack_properties($_[0], (properties_info)[9]);
		}
		if ($_[0]->{version} > 63) {
			$_[1]->unpack_properties($_[0], (properties_info)[4..5]);
		} elsif (($_[0]->{version} > 37) && ($_[0]->{version} <= 63)) {
			$_[1]->unpack_properties($_[0], (properties_info)[7..8]);
		}
	}
	if (($_[0]->{version} >= 110) && ($_[0]->{version} < 112)) {
		$_[1]->unpack_properties($_[0], (properties_info)[6]);
	}
}
sub state_write {
	cse_alife_trader_abstract::state_write(@_);
	cse_alife_monster_abstract::state_write(@_);
	if ($_[0]->{version} > 19) {
		if ($_[0]->{version} < 110) {
			$_[1]->pack_properties($_[0], (properties_info)[0..1]);
		}
		if ($_[0]->{version} > 35) {
			if ($_[0]->{version} < 110) {
				$_[1]->pack_properties($_[0], (properties_info)[2]);
			}
			if ($_[0]->{version} < 118) {
				$_[1]->pack_properties($_[0], (properties_info)[3]);
			}
		} else {
			$_[1]->pack_properties($_[0], (properties_info)[9]);
		}
		if ($_[0]->{version} > 63) {
			$_[1]->pack_properties($_[0], (properties_info)[4..5]);
		} elsif (($_[0]->{version} > 37) && ($_[0]->{version} <= 63)) {
			$_[1]->pack_properties($_[0], (properties_info)[7..8]);
		}
	}
	if (($_[0]->{version} >= 110) && ($_[0]->{version} < 112)) {
		$_[1]->pack_properties($_[0], (properties_info)[6]);
	}
}
sub state_import {
	cse_alife_trader_abstract::state_import(@_);
	cse_alife_monster_abstract::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_trader_abstract::state_export(@_);
	cse_alife_monster_abstract::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_trader_abstract::update_read(@_);
	cse_alife_monster_abstract::update_read(@_);
	if ($_[0]->{version} <= 109) {
		$_[1]->unpack_properties($_[0], upd_properties_info);
	}
}
sub update_write {
	cse_alife_trader_abstract::update_write(@_);
	cse_alife_monster_abstract::update_write(@_);
	if ($_[0]->{version} <= 109) {
		$_[1]->pack_properties($_[0], upd_properties_info);
	}
}
sub update_import {
	cse_alife_trader_abstract::update_import(@_);
	cse_alife_monster_abstract::update_import(@_);
	if ($_[0]->{version} <= 109) {
		$_[1]->import_properties($_[2], $_[0], upd_properties_info);
	}
}
sub update_export {
	cse_alife_trader_abstract::update_export(@_);
	cse_alife_monster_abstract::update_export(@_);
	if ($_[0]->{version} <= 109) {
		$_[1]->export_properties(undef, $_[0], upd_properties_info);
	}
}
#######################################################################
package cse_alife_object_idol; 
use strict;
use constant properties_info => (
	{ name => 'cse_alife_object_idol__unk1_sz',	type => 'sz',	default => '' },
	{ name => 'cse_alife_object_idol__unk2_u32',	type => 'u32',	default => 0 },
);
sub init {
	cse_alife_human_abstract::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_human_abstract::state_read(@_);
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	cse_alife_human_abstract::state_write(@_);
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	cse_alife_human_abstract::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_human_abstract::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_human_abstract::update_read(@_);
}
sub update_write {
	cse_alife_human_abstract::update_write(@_);
}
sub update_import {
	cse_alife_human_abstract::update_import(@_);
}
sub update_export {
	cse_alife_human_abstract::update_export(@_);
}
#######################################################################
package cse_alife_human_stalker;
use strict;
use constant properties_info => (
	{ name => 'cse_alife_human_stalker__unk1_bool', type => 'u8', default => 0 },
);
use constant upd_properties_info => (
	{ name => 'upd:start_dialog', type => 'sz' },
);
sub init {
	cse_alife_human_abstract::init(@_);
	cse_ph_skeleton::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_human_abstract::state_read(@_);
	if ($_[0]->{version} > 67) {
		cse_ph_skeleton::state_read(@_);
	}
	if (($_[0]->{version} > 90) && ($_[0]->{version} < 111)) {
		$_[1]->unpack_properties($_[0], properties_info);
	}
}
sub state_write {
	cse_alife_human_abstract::state_write(@_);
	if ($_[0]->{version} > 67) {
		cse_ph_skeleton::state_write(@_);
	}
	if (($_[0]->{version} > 90) && ($_[0]->{version} < 111)) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_human_abstract::state_import(@_);
	if ($_[0]->{version} > 67) {
		cse_ph_skeleton::state_import(@_);
	}
	if (($_[0]->{version} > 90) && ($_[0]->{version} < 111)) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_human_abstract::state_export(@_);
	if ($_[0]->{version} > 67) {
		cse_ph_skeleton::state_export(@_);
	}
	if (($_[0]->{version} > 90) && ($_[0]->{version} < 111)) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
sub update_read {
	cse_alife_human_abstract::update_read(@_);
	if ($_[0]->{version} > 94) {
		$_[1]->unpack_properties($_[0], upd_properties_info);
	}
}
sub update_write {
	cse_alife_human_abstract::update_write(@_);
	if ($_[0]->{version} > 94) {
		$_[1]->pack_properties($_[0], upd_properties_info);
	}
}
sub update_import {
	cse_alife_human_abstract::update_import(@_);
	if ($_[0]->{version} > 94) {
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
	}
}
sub update_export {
	cse_alife_human_abstract::update_export(@_);
	if ($_[0]->{version} > 94) {
	$_[1]->export_properties(__PACKAGE__, $_[0], upd_properties_info);
	}
}
#######################################################################
package cse_alife_creature_actor;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
	{ name => 'holder_id', type => 'h16', default => 0xffff },
);
use constant upd_properties_info => (
	{ name => 'upd:actor_state',		type => 'h16', default => 0  },
	{ name => 'upd:actor_accel_header',	type => 'h16', default => 0  },
	{ name => 'upd:actor_accel_data',	type => 'h32', default => 0  },
	{ name => 'upd:actor_velocity_header',	type => 'h16', default => 0  },
	{ name => 'upd:actor_velocity_data',	type => 'h32', default => 0  },
	{ name => 'upd:actor_radiation',	type => 'f32', default => 0  },
	{ name => 'upd:actor_radiation_pkd',	type => 'q16', default => 0  },
	{ name => 'upd:cse_alife_creature_actor_unk1_q16',	type => 'q16', default => 0  },
	{ name => 'upd:actor_weapon',		type => 'u8', default => 0  },
	{ name => 'upd:num_items',		type => 'u16', default => 0  },
	{ name => 'upd:actor_radiation_pkd_old',	type => 'q16_old', default => 0  },
);
sub init {
	cse_alife_creature_abstract::init(@_);
	cse_alife_trader_abstract::init(@_);
	cse_ph_skeleton::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_creature_abstract::state_read(@_);
	cse_alife_trader_abstract::state_read(@_);
	if ($_[0]->{version} > 91) {
		cse_ph_skeleton::state_read(@_);
	}
	if ($_[0]->{version} > 88) {
		$_[1]->unpack_properties($_[0], properties_info);
	}
}
sub state_write {
	cse_alife_creature_abstract::state_write(@_);
	cse_alife_trader_abstract::state_write(@_);
	if ($_[0]->{version} > 91) {
		cse_ph_skeleton::state_write(@_);
	}
	if ($_[0]->{version} > 88) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_creature_abstract::state_import(@_);
	cse_alife_trader_abstract::state_import(@_);
	if ($_[0]->{version} > 91) {
		cse_ph_skeleton::state_import(@_);
	}
	if ($_[0]->{version} > 88) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_creature_abstract::state_export(@_);
	cse_alife_trader_abstract::state_export(@_);
	if ($_[0]->{version} > 91) {
		cse_ph_skeleton::state_export(@_);
	}
	if ($_[0]->{version} > 88) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
sub update_read {
	cse_alife_creature_abstract::update_read(@_);
	cse_alife_trader_abstract::update_read(@_);
	$_[1]->unpack_properties($_[0], (upd_properties_info)[0..4]);
	if ($_[0]->{version} > 109) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[5]);
	} elsif ($_[0]->{version} > 40) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[6]);
	} else {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[10]);
	}
	if (($_[0]->{version} > 101) && ($_[0]->{version} <= 104)) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[7]);
	}
	$_[1]->unpack_properties($_[0], (upd_properties_info)[8]);
	if ($_[0]->{version} > 39) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[9]);
	}
	if (defined $_[0]->{'upd:num_items'}) {
		fail(__PACKAGE__.'::update_read', __LINE__, '$_[0]->{upd:num_items} == 0', 'unexpected upd:num_items') unless $_[0]->{'upd:num_items'} == 0;
	}
}
sub update_write {
	cse_alife_creature_abstract::update_write(@_);
	cse_alife_trader_abstract::update_write(@_);
	$_[1]->pack_properties($_[0], (upd_properties_info)[0..4]);
	if ($_[0]->{version} > 109) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[5]);
	} elsif ($_[0]->{version} > 40) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[6]);
	} else {
		$_[1]->pack_properties($_[0], (upd_properties_info)[10]);
	}
	if (($_[0]->{version} > 101) && ($_[0]->{version} <= 104)) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[7]);
	}
	$_[1]->pack_properties($_[0], (upd_properties_info)[8]);
	if ($_[0]->{version} > 39) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[9]);
	}
}
sub update_import {
	cse_alife_creature_abstract::update_import(@_);
	cse_alife_trader_abstract::update_import(@_);
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	cse_alife_creature_abstract::update_export(@_);
	cse_alife_trader_abstract::update_export(@_);
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package cse_smart_cover;
use strict;
use constant properties_info => (
	{ name => 'description',	type => 'sz',	default => '' },
	{ name => 'hold_position_time',	type => 'f32',	default => 0.0 },
	{ name => 'enter_min_enemy_distance',	type => 'f32',	default => 0.0 },
	{ name => 'exit_min_enemy_distance',	type => 'f32',	default => 0.0 },
	{ name => 'is_combat_cover',		type => 'u8',	default => 0 },
	{ name => 'MP_respawn',	type => 'u8',	default => 0 },
);
sub init {
	cse_alife_dynamic_object::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_dynamic_object::state_read(@_);
	cse_shape::state_read(@_);
	$_[1]->unpack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} >= 120) {
		$_[1]->unpack_properties($_[0], (properties_info)[2..3]);
	}
	if ($_[0]->{version} >= 122) {
		$_[1]->unpack_properties($_[0], (properties_info)[4]);
	}
	if ($_[0]->{version} >= 128) {
		$_[1]->unpack_properties($_[0], (properties_info)[5]);
	}
}
sub state_write {
	cse_alife_dynamic_object::state_write(@_);
	cse_shape::state_write(@_);
	$_[1]->pack_properties($_[0], (properties_info)[0..1]);
	if ($_[0]->{version} >= 120) {
		$_[1]->pack_properties($_[0], (properties_info)[2..3]);
	}
	if ($_[0]->{version} >= 122) {
		$_[1]->pack_properties($_[0], (properties_info)[4]);
	}
	if ($_[0]->{version} >= 128) {
		$_[1]->pack_properties($_[0], (properties_info)[5]);
	}
}
sub state_import {
	cse_alife_dynamic_object::state_import(@_);
	cse_shape::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_dynamic_object::state_export(@_);
	cse_shape::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_space_restrictor;
use constant eDefaultRestrictorTypeNone	=> 0x00;
use constant eDefaultRestrictorTypeOut	=> 0x01;
use constant eDefaultRestrictorTypeIn	=> 0x02;
use constant eRestrictorTypeNone	=> 0x03;
use constant eRestrictorTypeIn		=> 0x04;
use constant eRestrictorTypeOut		=> 0x05;
use strict;
use constant properties_info => (
	{ name => 'restrictor_type', type => 'u8', default => 0xff },
);
sub init {
	cse_alife_object::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	if ($_[0]->{version} > 14) {
		cse_alife_object::state_read(@_);
	}
	cse_shape::state_read(@_);
	if ($_[0]->{version} > 74) {
		$_[1]->unpack_properties($_[0], properties_info);
	}
}
sub state_write {
	if ($_[0]->{version} > 14) {
	cse_alife_object::state_write(@_);
	}
	cse_shape::state_write(@_);
	if ($_[0]->{version} > 74) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	if ($_[0]->{version} > 14) {
	cse_alife_object::state_import(@_);
	}
	cse_shape::state_import(@_);
	if ($_[0]->{version} > 74) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	if ($_[0]->{version} > 14) {
	cse_alife_object::state_export(@_);
	}
	cse_shape::state_export(@_);
	if ($_[0]->{version} > 74) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
#######################################################################
package cse_alife_team_base_zone;
use strict;
use constant properties_info => (
	{ name => 'team', type => 'u8', default => 0 },
);
sub init {
	cse_alife_space_restrictor::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_space_restrictor::state_read(@_);
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	cse_alife_space_restrictor::state_write(@_);
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	cse_alife_space_restrictor::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_space_restrictor::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_level_changer;
use strict;
use constant properties_info => (
	{ name => 'cse_alife_level_changer__unk1_s32',	type => 's32',	default => -1 },
	{ name => 'cse_alife_level_changer__unk2_s32',	type => 's32',	default => -1 },
	{ name => 'dest_game_vertex_id',	type => 'u16',	default => 0 },
	{ name => 'dest_level_vertex_id',	type => 'u32',	default => 0 },
	{ name => 'dest_position',		type => 'f32v3',default => [0,0,0] },
	{ name => 'dest_direction',		type => 'f32v3',default => [0,0,0] },
	{ name => 'angle_y',		type => 'f32',default => 0.0 },
	{ name => 'dest_level_name',		type => 'sz',	default => '' },
	{ name => 'dest_graph_point',		type => 'sz',	default => '' },
	{ name => 'silent_mode',		type => 'u8',	default => 0 },
);
sub init {
	cse_alife_space_restrictor::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_space_restrictor::state_read(@_);
	if ($_[0]->{version} < 34) {
		$_[1]->unpack_properties($_[0], (properties_info)[0..1]);
	} else {
		$_[1]->unpack_properties($_[0], (properties_info)[2..4]);
		if ($_[0]->{version} > 53) {
			$_[1]->unpack_properties($_[0], (properties_info)[5]);
		} else {
			$_[1]->unpack_properties($_[0], (properties_info)[6]);
		}
	}
	$_[1]->unpack_properties($_[0], (properties_info)[7..8]);
	if ($_[0]->{version} > 116) {
		$_[1]->unpack_properties($_[0], (properties_info)[9]);
	}
}
sub state_write {
	cse_alife_space_restrictor::state_write(@_);
	if ($_[0]->{version} < 34) {
		$_[1]->pack_properties($_[0], (properties_info)[0..1]);
	} else {
		$_[1]->pack_properties($_[0], (properties_info)[2..4]);
		if ($_[0]->{version} > 53) {
			$_[1]->pack_properties($_[0], (properties_info)[5]);
		} else {
			$_[1]->pack_properties($_[0], (properties_info)[6]);
		}
	}
	$_[1]->pack_properties($_[0], (properties_info)[7..8]);
	if ($_[0]->{version} > 116) {
		$_[1]->pack_properties($_[0], (properties_info)[9]);
	}
}
sub state_import {
	cse_alife_space_restrictor::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_space_restrictor::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package cse_alife_smart_zone;
use strict;
sub init {
	cse_alife_space_restrictor::init(@_);
}
sub state_read {
	cse_alife_space_restrictor::state_read(@_);
}
sub state_write {
	cse_alife_space_restrictor::state_write(@_);
}
sub state_import {
	cse_alife_space_restrictor::state_import(@_);
}
sub state_export {
	cse_alife_space_restrictor::state_export(@_);
}
#######################################################################
package cse_alife_custom_zone;
use strict;
use constant properties_info => (
	{ name => 'max_power',		type => 'f32',	default => 0.0 },
	{ name => 'attenuation',		type => 'f32',	default => 0.0 },
	{ name => 'period',	type => 'u32',	default => 0 },	
	{ name => 'owner_id',		type => 'h32',	default => 0xffffffff },
	{ name => 'enabled_time',	type => 'u32',	default => 0 },
	{ name => 'disabled_time',	type => 'u32',	default => 0 },
	{ name => 'start_time_shift',	type => 'u32',	default => 0 },
);
use constant upd_properties_info => (
	{ name => 'upd:cse_alife_custom_zone__unk1_h32',		type => 'h32',	default => 0xffffffff },
);
sub init {
	cse_alife_space_restrictor::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_space_restrictor::state_read(@_);
	$_[1]->unpack_properties($_[0], (properties_info)[0]);
	if ($_[0]->{version} < 113) {
		$_[1]->unpack_properties($_[0], (properties_info)[1..2]);
	}
	if (($_[0]->{version} > 66) && ($_[0]->{version} < 118)) {
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
	}
	if ($_[0]->{version} > 102) {
		$_[1]->unpack_properties($_[0], (properties_info)[3]);
	}
	if ($_[0]->{version} > 105) {
		$_[1]->unpack_properties($_[0], (properties_info)[4..5]);
	}
	if ($_[0]->{version} > 106) {
		$_[1]->unpack_properties($_[0], (properties_info)[6]);
	}
}
sub state_write {
	cse_alife_space_restrictor::state_write(@_);
	$_[1]->pack_properties($_[0], (properties_info)[0]);
	if ($_[0]->{version} < 113) {
		$_[1]->pack_properties($_[0], (properties_info)[1..2]);
	}
	if (($_[0]->{version} > 66) && ($_[0]->{version} < 118)) {
		$_[1]->pack_properties($_[0], (properties_info)[1]);
	}
	if ($_[0]->{version} > 102) {
		$_[1]->pack_properties($_[0], (properties_info)[3]);
	}
	if ($_[0]->{version} > 105) {
		$_[1]->pack_properties($_[0], (properties_info)[4..5]);
	}
	if ($_[0]->{version} > 106) {
		$_[1]->pack_properties($_[0], (properties_info)[6]);
	}
}
sub state_import {
	cse_alife_space_restrictor::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_space_restrictor::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	if (($_[0]->{version} > 101) && ($_[0]->{version} <= 118) && ($_[0]->{script_version} <= 5)) {
		$_[1]->unpack_properties($_[0], upd_properties_info);
	}
}
sub update_write {
	if (($_[0]->{version} > 101) && ($_[0]->{version} <= 118) && ($_[0]->{script_version} <= 5)) {
		$_[1]->pack_properties($_[0], upd_properties_info);
	}
}
sub update_import {
	if (($_[0]->{version} > 101) && ($_[0]->{version} <= 118) && ($_[0]->{script_version} <= 5)) {
		$_[1]->import_properties($_[2], $_[0], upd_properties_info);
	}
}
sub update_export {
	if (($_[0]->{version} > 101) && ($_[0]->{version} <= 118) && ($_[0]->{script_version} <= 5)) {
		$_[1]->export_properties(undef, $_[0], upd_properties_info);
	}
}
######################################################################
package cse_alife_anomalous_zone;
use strict;
use constant properties_info => (
	{ name => 'offline_interactive_radius',	type => 'f32',	default => 0.0 },
	{ name => 'artefact_birth_probability',	type => 'f32',	default => 0.0 },
	{ name => 'artefact_spawns',	type => 'afspawns_u32',	default => ['none'] },
	{ name => 'artefact_spawns',	type => 'afspawns',	default => ['none'] },
	{ name => 'artefact_spawn_count',	type => 'u16',	default => 0 },
	{ name => 'artefact_position_offset',	type => 'h32',	default => 0 },
	{ name => 'start_time_shift',	type => 'u32',	default => 0 },
	{ name => 'cse_alife_anomalous_zone__unk2_f32',	type => 'f32',	default => 0.0 },
	{ name => 'min_start_power',	type => 'f32',	default => 0.0 },
	{ name => 'max_start_power',	type => 'f32',	default => 0.0 },
	{ name => 'power_artefact_factor',	type => 'f32',	default => 0.0 },
	{ name => 'owner_id',	type => 'h32',	default => 0 },
);
sub init {
	cse_alife_custom_zone::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_custom_zone::state_read(@_);
	if ($_[0]->{version} > 21) {
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
		if ($_[0]->{version} < 113) {
			$_[1]->unpack_properties($_[0], (properties_info)[1]);
			if ($_[0]->{version} < 26) {
				$_[1]->unpack_properties($_[0], (properties_info)[2]);
			} else {
				$_[1]->unpack_properties($_[0], (properties_info)[3]);
			}
		}
	}
	if ($_[0]->{version} > 25) {
		$_[1]->unpack_properties($_[0], (properties_info)[4..5]);
	}
	if (($_[0]->{version} > 27) && ($_[0]->{version} < 67)) {
		$_[1]->unpack_properties($_[0], (properties_info)[6]);
	}
	if (($_[0]->{version} > 38) && ($_[0]->{version} < 113)) {
		$_[1]->unpack_properties($_[0], (properties_info)[7]);
	}
	if ($_[0]->{version} > 78 && $_[0]->{version} < 113) {
		$_[1]->unpack_properties($_[0], (properties_info)[8..10]);
	}
	if ($_[0]->{version} == 102) {
		$_[1]->unpack_properties($_[0], (properties_info)[11]);
	}
}
sub state_write {
	cse_alife_custom_zone::state_write(@_);
	if ($_[0]->{version} > 21) {
		$_[1]->pack_properties($_[0], (properties_info)[0]);
		if ($_[0]->{version} < 113) {
			$_[1]->pack_properties($_[0], (properties_info)[1]);
			if ($_[0]->{version} < 26) {
				$_[1]->pack_properties($_[0], (properties_info)[2]);
			} else {
				$_[1]->pack_properties($_[0], (properties_info)[3]);
			}
		}
	}
	if ($_[0]->{version} > 25) {
		$_[1]->pack_properties($_[0], (properties_info)[4..5]);
	}
	if (($_[0]->{version} > 27) && ($_[0]->{version} < 67)) {
		$_[1]->pack_properties($_[0], (properties_info)[6]);
	}
	if (($_[0]->{version} > 38) && ($_[0]->{version} < 113)) {
		$_[1]->pack_properties($_[0], (properties_info)[7]);
	}
	if ($_[0]->{version} > 78 && $_[0]->{version} < 113) {
		$_[1]->pack_properties($_[0], (properties_info)[8..10]);
	}
	if ($_[0]->{version} == 102) {
		$_[1]->pack_properties($_[0], (properties_info)[11]);
	}
}
sub state_import {
	cse_alife_custom_zone::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_custom_zone::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_custom_zone::update_read(@_);
}
sub update_write {
	cse_alife_custom_zone::update_write(@_);
}
sub update_import {
	cse_alife_custom_zone::update_import(@_);
}
sub update_export {
	cse_alife_custom_zone::update_export(@_);
}
#######################################################################
package cse_alife_zone_visual;
use strict;
use constant properties_info => (
	{ name => 'idle_animation',	type => 'sz',	default => '' },
	{ name => 'attack_animation',	type => 'sz',	default => '' },
);
sub init {
	cse_alife_anomalous_zone::init(@_);
	cse_visual::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_anomalous_zone::state_read(@_);
	if (($_[0]->{version} > 104) || ($_[0]->{section_name} eq 'zone_burning_fuzz1')) {
		cse_visual::state_read(@_);
		$_[1]->unpack_properties($_[0], properties_info);
	}
}
sub state_write {
	cse_alife_anomalous_zone::state_write(@_);
	if (($_[0]->{version} > 104) || ($_[0]->{section_name} eq 'zone_burning_fuzz1')) {
		cse_visual::state_write(@_);
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_anomalous_zone::state_import(@_);
	if (($_[0]->{version} > 104) || ($_[0]->{section_name} eq 'zone_burning_fuzz1')) {
		cse_visual::state_import(@_);
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_anomalous_zone::state_export(@_);
	if (($_[0]->{version} > 104) || ($_[0]->{section_name} eq 'zone_burning_fuzz1')) {
		cse_visual::state_export(@_);
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
sub update_read {
	cse_alife_custom_zone::update_read(@_);
}
sub update_write {
	cse_alife_custom_zone::update_write(@_);
}
sub update_import {
	cse_alife_custom_zone::update_import(@_);
}
sub update_export {
	cse_alife_custom_zone::update_export(@_);
}
#######################################################################
package cse_alife_torrid_zone;
use strict;
sub init {
	cse_alife_custom_zone::init(@_);
	cse_motion::init(@_);
}
sub state_read {
	cse_alife_custom_zone::state_read(@_);
	cse_motion::state_read(@_);
}
sub state_write {
	cse_alife_custom_zone::state_write(@_);
	cse_motion::state_write(@_);
}
sub state_import {
	cse_alife_custom_zone::state_import(@_);
	cse_motion::state_import(@_);
}
sub state_export {
	cse_alife_custom_zone::state_export(@_);
	cse_motion::state_export(@_);
}
sub update_read {
	cse_alife_custom_zone::update_read(@_);
}
sub update_write {
	cse_alife_custom_zone::update_write(@_);
}
sub update_import {
	cse_alife_custom_zone::update_import(@_);
}
sub update_export {
	cse_alife_custom_zone::update_export(@_);
}
#######################################################################
package cse_alife_inventory_item;
use strict;
use stkutils::debug 'fail';
use constant FLAG_NO_POSITION => 0x8000;
use constant FL_IS_2942 => 0x04;
use constant properties_info => (
	{ name => 'condition', type => 'f32', default => 0.0 },
	{ name => 'upgrades', type => 'l32szv', default => [''] },
);
use constant upd_properties_info => (
	{ name => 'upd:num_items',			type => 'h8', default => 0 },
	{ name => 'upd:force',				type => 'f32v3', default => [0.0,0.0,0.0]  },			# junk in COP
	{ name => 'upd:torque',				type => 'f32v3', default => [0.0,0.0,0.0]  },			# junk in COP
	{ name => 'upd:position',			type => 'f32v3', default => [0.0,0.0,0.0]  },
	{ name => 'upd:quaternion',			type => 'f32v4', default => [0.0,0.0,0.0,0.0]  },
	{ name => 'upd:angular_velocity',	type => 'f32v3', default => [0.0,0.0,0.0]  },
	{ name => 'upd:linear_velocity',	type => 'f32v3', default => [0.0,0.0,0.0]  },
	{ name => 'upd:enabled',			type => 'u8', default => 0 },
	{ name => 'upd:quaternion_pkd',			type => 'q8v4', default => [0,0,0,0]  }, #SOC
	{ name => 'upd:angular_velocity_pkd',	type => 'q8v3', default => [0,0,0]  }, #SOC
	{ name => 'upd:linear_velocity_pkd',	type => 'q8v3', default => [0,0,0]  }, #SOC
	{ name => 'upd:condition',			type => 'f32', default => 0  },
	{ name => 'upd:timestamp',			type => 'u32', default => 0  },
	{ name => 'upd:num_items_old',			type => 'u16', default => 0  }, #old format
	{ name => 'upd:cse_alife_inventory_item__unk1_u8',			type => 'u8', default => 0  },
);
sub init {
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	if ($_[0]->{version} > 52) {
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
	}
	if ($_[0]->{version} > 123) {
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
	}
}
sub state_write {
	if ($_[0]->{version} > 52) {
		$_[1]->pack_properties($_[0], (properties_info)[0]);
	}
	if ($_[0]->{version} > 123) {
		$_[1]->pack_properties($_[0], (properties_info)[1]);
	}
}
sub state_import {
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	if (($_[0]->{version} >= 122) && ($_[0]->{version} <= 128)) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[0]);
		if ($_[0]->{'upd:num_items'} != 0) {
			$_[1]->unpack_properties($_[0], (upd_properties_info)[1..4]);
			my $flags = $_[0]->{'upd:num_items'} >> 5;
			if (($flags & 0x2) == 0) {
				$_[1]->unpack_properties($_[0], (upd_properties_info)[5]);
			}
			if (($flags & 0x4) == 0) {
				$_[1]->unpack_properties($_[0], (upd_properties_info)[6]);
			}
			if ($_[1]->resid() != 0) {
				$_[1]->unpack_properties($_[0], (upd_properties_info)[7]);
			}
		}
	} elsif (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[0]);
		if ($_[0]->{'upd:num_items'} != 0) {
			$_[1]->unpack_properties($_[0], (upd_properties_info)[3]);
			$_[1]->unpack_properties($_[0], (upd_properties_info)[8]);
			my $flags = $_[0]->{'upd:num_items'} >> 5;
			if (($flags & 0x02 || $flags & 0x04) && $_[1]->resid() == 6) {
				$_[0]->{flags} |= FL_IS_2942;
			}
			if (first_patch($_[0]) || (($flags & 0x02) == 0)) {
				fail(__PACKAGE__.'::update_read', __LINE__, '[1]->length() >= 3', 'unexpected size') unless $_[1]->resid() >= 3;
				$_[1]->unpack_properties($_[0], (upd_properties_info)[9]);
			}
			if (first_patch($_[0]) || (($flags & 0x04) == 0)) {
				fail(__PACKAGE__.'::update_read', __LINE__, '[1]->length() >= 3', 'unexpected size') unless $_[1]->resid() >= 3;
				$_[1]->unpack_properties($_[0], (upd_properties_info)[10]);
			}
		}
	} else {
		if (($_[0]->{version} > 59) &&($_[0]->{version} <= 63)) {
			$_[1]->unpack_properties($_[0], (upd_properties_info)[14]);
		}
		$_[1]->unpack_properties($_[0], (upd_properties_info)[11..13]);
		my $flags = $_[0]->{'upd:num_items_old'};
		if ($flags != 0x8000) {
			$_[1]->unpack_properties($_[0], (upd_properties_info)[3]);
		}
		if ($flags & ~0x8000) {
			$_[1]->unpack_properties($_[0], (upd_properties_info)[7]);
			$_[1]->unpack_properties($_[0], (upd_properties_info)[5..6]);
			$_[1]->unpack_properties($_[0], (upd_properties_info)[1..2]);
			$_[1]->unpack_properties($_[0], (upd_properties_info)[4]);
		}
	}
}
sub update_write {
	if (($_[0]->{version} >= 122) && ($_[0]->{version} <= 128)) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[0]);
		if ($_[0]->{'upd:num_items'} != 0) {
			$_[1]->pack_properties($_[0], (upd_properties_info)[1..4]);
			my $flags = $_[0]->{'upd:num_items'} >> 5;
			if (($flags & 0x2) == 0) {
				$_[1]->pack_properties($_[0], (upd_properties_info)[5]);
			}
			if (($flags & 0x4) == 0) {
				$_[1]->pack_properties($_[0], (upd_properties_info)[6]);
			}
			if ($_[1]->resid() != 0) {
				$_[1]->pack_properties($_[0], (upd_properties_info)[7]);
			}
		}
	} elsif (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
	my $flags = ($_[0]->{'upd:num_items'});
	my $mask = $flags >> 5;
		$_[1]->pack_properties($_[0], (upd_properties_info)[0]);
		if ($flags != 0) {
			$_[1]->pack_properties($_[0], (upd_properties_info)[3]);
			$_[1]->pack_properties($_[0], (upd_properties_info)[8]);
			if (first_patch($_[0]) || (($mask & 0x02) == 0)) {
				$_[1]->pack_properties($_[0], (upd_properties_info)[9]);
			}
			if (first_patch($_[0]) || (($mask & 0x04) == 0)) {
				$_[1]->pack_properties($_[0], (upd_properties_info)[10]);
			}
		}
	} else {
		if (($_[0]->{version} > 59) &&($_[0]->{version} <= 63)) {
			$_[1]->pack_properties($_[0], (upd_properties_info)[14]);
		}
		$_[1]->pack_properties($_[0], (upd_properties_info)[11..13]);
		my $flags = $_[0]->{'upd:num_items_old'};
		if ($flags != 0x8000) {
			$_[1]->pack_properties($_[0], (upd_properties_info)[3]);
		}
		if ($flags & ~0x8000) {
			$_[1]->pack_properties($_[0], (upd_properties_info)[7]);
			$_[1]->pack_properties($_[0], (upd_properties_info)[5..6]);
			$_[1]->pack_properties($_[0], (upd_properties_info)[1..2]);
			$_[1]->pack_properties($_[0], (upd_properties_info)[4]);
		}
	}
}
sub update_import {
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
sub first_patch {
	return $_[0]->{flags} & FL_IS_2942;
}
#######################################################################
package cse_alife_item;
use strict;
sub init {
	cse_alife_dynamic_object_visual::init(@_);
	cse_alife_inventory_item::init(@_);
}
sub state_read {
	cse_alife_dynamic_object_visual::state_read(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::state_read(@_);
	}
}
sub state_write {
	cse_alife_dynamic_object_visual::state_write(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::state_write(@_);
	}
}
sub state_import {
	cse_alife_dynamic_object_visual::state_import(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::state_import(@_);
	}
}
sub state_export {
	cse_alife_dynamic_object_visual::state_export(@_);
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::state_export(@_);
	}
}
sub update_read {
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::update_read(@_);
	}
}
sub update_write {
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::update_write(@_);
	}
}
sub update_import {
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::update_import(@_);
	}
}
sub update_export {
	if ($_[0]->{version} > 39) {
		cse_alife_inventory_item::update_export(@_);
	}
}
#######################################################################
package cse_alife_item_binocular;
use strict;
use constant properties_info => (
	{ name => 'cse_alife_item__unk1_s16', type => 's16', default => 0 },
	{ name => 'cse_alife_item__unk2_s16', type => 's16', default => 0 },
	{ name => 'cse_alife_item__unk3_s8', type => 's8', default => 0 },
);
sub init {
	cse_alife_item::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_item::state_read(@_);
	if ($_[0]->{version} < 37) {
		$_[1]->unpack_properties($_[0], properties_info);
	}
}
sub state_write {
	cse_alife_item::state_write(@_);
	if ($_[0]->{version} < 37) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_item::state_import(@_);
	if ($_[0]->{version} < 37) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_item::state_write(@_);
	if ($_[0]->{version} < 37) {
		$_[1]->export_properties(undef, $_[0], properties_info);
	}
}
sub update_read {
	cse_alife_item::update_read(@_);
}
sub update_write {
	cse_alife_item::update_write(@_);
}
sub update_import {
	cse_alife_item::update_import(@_);
}
sub update_export {
	cse_alife_item::update_export(@_);
}
#######################################################################
package cse_alife_item_torch;
use strict;
use constant flTorchActive		=> 0x01;
use constant flTorchNightVisionActive	=> 0x02;
use constant flTorchUnknown		=> 0x04;
use constant properties_info => (
	{ name => 'main_color',		type => 'h32',	default => 0x00ffffff },
	{ name => 'main_color_animator',type => 'sz',	default => '' },
	{ name => 'animation',	type => 'sz',	default => '$editor' },
	{ name => 'ambient_radius',	type => 'f32',	default => 0.0 },
	{ name => 'main_cone_angle',	type => 'q8',	default => 0.0 },
	{ name => 'main_virtual_size',	type => 'f32',	default => 0.0 },
	{ name => 'glow_texture',	type => 'sz',	default => '' },
	{ name => 'glow_radius',	type => 'f32',	default => 0.0 },
	{ name => 'cse_alife_object_hanging_lamp__unk3_u8',	type => 'u16',	default => 0 },
);
use constant upd_properties_info => (
	{ name => 'upd:torch_flags', type => 'u8', default => -1 },
);
sub init {
	cse_alife_item::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	if ($_[0]->{version} > 20) {
		cse_alife_item::state_read(@_);
	}
	if ($_[0]->{version} < 48) {
		$_[1]->unpack_properties($_[0], (properties_info)[0..5]);
		if ($_[0]->{version} > 40) {
			$_[1]->unpack_properties($_[0], (properties_info)[6..7]);
		}
		if ($_[0]->{version} > 45) {
			$_[1]->unpack_properties($_[0], (properties_info)[8]);
		}
	}
}
sub state_write {
	if ($_[0]->{version} > 20) {
		cse_alife_item::state_write(@_);
	}
	if ($_[0]->{version} < 48) {
		$_[1]->pack_properties($_[0], (properties_info)[0..5]);
		if ($_[0]->{version} > 40) {
			$_[1]->pack_properties($_[0], (properties_info)[6..7]);
		}
		if ($_[0]->{version} > 45) {
			$_[1]->pack_properties($_[0], (properties_info)[8]);
		}
	}
}
sub state_import {
	if ($_[0]->{version} > 20) {
		cse_alife_item::state_import(@_);
	}
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	if ($_[0]->{version} > 20) {
		cse_alife_item::state_export(@_);
	}
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_item::update_read(@_);
	$_[1]->unpack_properties($_[0], upd_properties_info);
}
sub update_write {
	cse_alife_item::update_write(@_);
	$_[1]->pack_properties($_[0], upd_properties_info);
}
sub update_import {
	cse_alife_item::update_import(@_);
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	cse_alife_item::update_export(@_);
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package cse_alife_item_detector;
use strict;
sub init {
	cse_alife_item::init(@_);
}
sub state_read {
	if ($_[0]->{version} > 20) {
		cse_alife_item::state_read(@_);
	}
}
sub state_write {
	if ($_[0]->{version} > 20) {
		cse_alife_item::state_write(@_);
	}
}
sub state_import {
	if ($_[0]->{version} > 20) {
	cse_alife_item::state_import(@_);
	}
}
sub state_export {
	if ($_[0]->{version} > 20) {
	cse_alife_item::state_export(@_);
	}
}
sub update_read {
	if ($_[0]->{version} > 20) {
		cse_alife_item::update_read(@_);
	}
}
sub update_write {
	if ($_[0]->{version} > 20) {
		cse_alife_item::update_write(@_);
	}
}
sub update_import {
	if ($_[0]->{version} > 20) {
		cse_alife_item::update_import(@_);
	}
}
sub update_export {
	if ($_[0]->{version} > 20) {
		cse_alife_item::update_export(@_);
	}
}
#######################################################################
package cse_alife_item_artefact;
use strict;
sub init {
	cse_alife_item::init(@_);
}
sub state_read {
	cse_alife_item::state_read(@_);
}
sub state_write {
	cse_alife_item::state_write(@_);
}
sub state_import {
	cse_alife_item::state_import(@_);
}
sub state_export {
	cse_alife_item::state_export(@_);
}
sub update_read {
	cse_alife_item::update_read(@_);
}
sub update_write {
	cse_alife_item::update_write(@_);
}
sub update_import {
	cse_alife_item::update_import(@_);
}
sub update_export {
	cse_alife_item::update_export(@_);
}
#######################################################################
package cse_alife_item_grenade;
use strict;
sub init {
	cse_alife_item::init(@_);
}
sub state_read {
	cse_alife_item::state_read(@_);
}
sub state_write {
	cse_alife_item::state_write(@_);
}
sub state_import {
	cse_alife_item::state_import(@_);
}
sub state_export {
	cse_alife_item::state_export(@_);
}
sub update_read {
	cse_alife_item::update_read(@_);
}
sub update_write {
	cse_alife_item::update_write(@_);
}
sub update_import {
	cse_alife_item::update_import(@_);
}
sub update_export {
	cse_alife_item::update_export(@_);
}
#######################################################################
package cse_alife_item_explosive;
use strict;
sub init {
	cse_alife_item::init(@_);
}
sub state_read {
	cse_alife_item::state_read(@_);
}
sub state_write {
	cse_alife_item::state_write(@_);
}
sub state_import {
	cse_alife_item::state_import(@_);
}
sub state_export {
	cse_alife_item::state_export(@_);
}
sub update_read {
	cse_alife_item::update_read(@_);
}
sub update_write {
	cse_alife_item::update_write(@_);
}
sub update_import {
	cse_alife_item::update_import(@_);
}
sub update_export {
	cse_alife_item::update_export(@_);
}
#######################################################################
package cse_alife_item_bolt;
use strict;
sub init {
	cse_alife_item::init(@_);
}
sub state_read {
	cse_alife_item::state_read(@_);
}
sub state_write {
	cse_alife_item::state_write(@_);
}
sub state_import {
	cse_alife_item::state_import(@_);
}
sub state_export {
	cse_alife_item::state_export(@_);
}
sub update_read {
	cse_alife_item::update_read(@_);
}
sub update_write {
	cse_alife_item::update_write(@_);
}
sub update_import {
	cse_alife_item::update_import(@_);
}
sub update_export {
	cse_alife_item::update_export(@_);
}
#######################################################################
package cse_alife_item_custom_outfit;
use strict;
use constant upd_properties_info => (
	{ name => 'upd:condition', type => 'q8', default => 0},
);
sub init {
	cse_alife_item::init(@_);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_item::state_read(@_);
}
sub state_write {
	cse_alife_item::state_write(@_);
}
sub state_import {
	cse_alife_item::state_import(@_);
}
sub state_export {
	cse_alife_item::state_export(@_);
}
sub update_read {
	cse_alife_item::update_read(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->unpack_properties($_[0], upd_properties_info);
	}
}
sub update_write {
	cse_alife_item::update_write(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->pack_properties($_[0], upd_properties_info);
	}
}
sub update_import {
	cse_alife_item::update_import(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->import_properties($_[2], $_[0], upd_properties_info);
	}
}
sub update_export {
	cse_alife_item::update_export(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->export_properties(undef, $_[0], upd_properties_info);
	}
}
#######################################################################
package cse_alife_item_helmet;
use strict;
use constant upd_properties_info => (
	{ name => 'upd:condition', type => 'q8', default => 0},
);
sub init {
	cse_alife_item::init(@_);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_item::state_read(@_);
}
sub state_write {
	cse_alife_item::state_write(@_);
}
sub state_import {
	cse_alife_item::state_import(@_);
}
sub state_export {
	cse_alife_item::state_export(@_);
}
sub update_read {	
	cse_alife_item::update_read(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->unpack_properties($_[0], upd_properties_info);
	}
}
sub update_write {
	cse_alife_item::update_write(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->pack_properties($_[0], upd_properties_info);
	}
}
sub update_import {
	cse_alife_item::update_import(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->import_properties($_[2], $_[0], upd_properties_info);
	}
}
sub update_export {
	cse_alife_item::update_export(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->export_properties(undef, $_[0], upd_properties_info);
	}
}
#######################################################################
package cse_alife_item_pda;
use strict;
use constant properties_info => (
	{ name => 'original_owner',	type => 'u16',	default => 0 },
	{ name => 'specific_character',	type => 'sz',	default => '' },
	{ name => 'info_portion',	type => 'sz',	default => '' },
	{ name => 'cse_alife_item_pda__unk1_s32',	type => 's32',	default => -1 },
	{ name => 'cse_alife_item_pda__unk2_s32',	type => 's32',	default => -1 },
);
sub init {
	cse_alife_item::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_item::state_read(@_);
	if ($_[0]->{version} > 58) {
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
	}
	if ($_[0]->{version} > 89) {
		if ($_[0]->{version} < 98) {
			$_[1]->unpack_properties($_[0], (properties_info)[3..4]);
		} else {
			$_[1]->unpack_properties($_[0], (properties_info)[1..2]);
		}
	}
}
sub state_write {
	cse_alife_item::state_write(@_);
	if ($_[0]->{version} > 58) {
		$_[1]->pack_properties($_[0], (properties_info)[0]);
	}
	if ($_[0]->{version} > 89) {
		if ($_[0]->{version} < 98) {
			$_[1]->pack_properties($_[0], (properties_info)[3..4]);
		} else {
			$_[1]->pack_properties($_[0], (properties_info)[1..2]);
		}
	}
}
sub state_import {
	cse_alife_item::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_item::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_item::update_read(@_);
}
sub update_write {
	cse_alife_item::update_write(@_);
}
sub update_import {
	cse_alife_item::update_import(@_);
}
sub update_export {
	cse_alife_item::update_export(@_);
}
#######################################################################
package cse_alife_item_document;
use strict;
use constant properties_info => (
	{ name => 'info_portion', type => 'sz', default => '' },
	{ name => 'info_id', type => 'u16', default => 0 },
);
sub init {
	cse_alife_item::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_item::state_read(@_);
	if ($_[0]->{version} < 98) {
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
	} else {
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
	}
}
sub state_write {
	cse_alife_item::state_write(@_);
	if ($_[0]->{version} < 98) {
		$_[1]->pack_properties($_[0], (properties_info)[1]);
	} else {
		$_[1]->pack_properties($_[0], (properties_info)[0]);
	}
}
sub state_import {
	cse_alife_item::state_import(@_);
	if ($_[0]->{version} < 98) {
		$_[1]->import_properties($_[2], $_[0], (properties_info)[1]);
	} else {
		$_[1]->import_properties($_[2], $_[0], (properties_info)[0]);
	}
}
sub state_export {
	cse_alife_item::state_export(@_);
	if ($_[0]->{version} < 98) {
		$_[1]->export_properties(__PACKAGE__, $_[0], (properties_info)[1]);
	} else {
		$_[1]->export_properties(__PACKAGE__, $_[0], (properties_info)[0]);
	}
}
sub update_read {
	cse_alife_item::update_read(@_);
}
sub update_write {
	cse_alife_item::update_write(@_);
}
sub update_import {
	cse_alife_item::update_import(@_);
}
sub update_export {
	cse_alife_item::update_export(@_);
}
#######################################################################
package cse_alife_item_ammo;
use strict;
use constant properties_info => (
	{ name => 'ammo_left', type => 'u16', default => 0 },
);
use constant upd_properties_info => (
	{ name => 'upd:ammo_left', type => 'u16', default => 0},
);
sub init {
	cse_alife_item::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_item::state_read(@_);
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	cse_alife_item::state_write(@_);
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	cse_alife_item::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_item::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_item::update_read(@_);
	$_[1]->unpack_properties($_[0], upd_properties_info);
}
sub update_write {
	cse_alife_item::update_write(@_);
	$_[1]->pack_properties($_[0], upd_properties_info);
}
sub update_import {
	cse_alife_item::update_import(@_);
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	cse_alife_item::update_export(@_);
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package cse_alife_item_weapon;
use strict;
use constant flAddonSilencer	=> 0x01;
use constant flAddonLauncher	=> 0x02;
use constant flAddonScope	=> 0x04;
use constant properties_info => (
	{ name => 'ammo_current',	type => 'u16',	default => 0 },
	{ name => 'ammo_elapsed',	type => 'u16',	default => 0 },
	{ name => 'weapon_state',	type => 'u8',	default => 0 },
	{ name => 'addon_flags',	type => 'u8',	default => 0 },
	{ name => 'ammo_type',		type => 'u8',	default => 0 },
	{ name => 'cse_alife_item_weapon__unk1_u8',		type => 'u8',	default => 0 },
);
use constant upd_properties_info => (
	{ name => 'upd:condition',	type => 'q8', default => 0 },
	{ name => 'upd:weapon_flags',	type => 'u8', default => 0  },
	{ name => 'upd:ammo_elapsed',	type => 'u16', default => 0  },
	{ name => 'upd:addon_flags',	type => 'u8', default => 0  },	
	{ name => 'upd:ammo_type',	type => 'u8', default => 0  },
	{ name => 'upd:weapon_state',	type => 'u8', default => 0  },
	{ name => 'upd:weapon_zoom',	type => 'u8', default => 0  },
	{ name => 'upd:ammo_current',	type => 'u16', default => 0  },
	{ name => 'upd:position',	type => 'f32v3', default => [0,0,0]  },
	{ name => 'upd:timestamp',	type => 'u32', default => 0  },
);
sub init {
	cse_alife_item::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_item::state_read(@_);
	$_[1]->unpack_properties($_[0], (properties_info)[0..2]);
	if ($_[0]->{version} >= 40) {
		$_[1]->unpack_properties($_[0], (properties_info)[3]);
	}
	if ($_[0]->{version} > 46) {
		$_[1]->unpack_properties($_[0], (properties_info)[4]);
	}
	if ($_[0]->{version} > 122) {
		$_[1]->unpack_properties($_[0], (properties_info)[5]);
	}
}
sub state_write {
	cse_alife_item::state_write(@_);
	$_[1]->pack_properties($_[0], (properties_info)[0..2]);
	if ($_[0]->{version} >= 40) {
		$_[1]->pack_properties($_[0], (properties_info)[3]);
	}
	if ($_[0]->{version} > 46) {
		$_[1]->pack_properties($_[0], (properties_info)[4]);
	}
	if ($_[0]->{version} > 122) {
		$_[1]->pack_properties($_[0], (properties_info)[5]);
	}
}
sub state_import {
	cse_alife_item::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_item::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_item::update_read(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[0]);
	}
	if ($_[0]->{version} > 39) {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[1..6]);
	} else {
		$_[1]->unpack_properties($_[0], (upd_properties_info)[9]);
		$_[1]->unpack_properties($_[0], (upd_properties_info)[1]);
		$_[1]->unpack_properties($_[0], (upd_properties_info)[7]);
		$_[1]->unpack_properties($_[0], (upd_properties_info)[2]);
		$_[1]->unpack_properties($_[0], (upd_properties_info)[8]);
		$_[1]->unpack_properties($_[0], (upd_properties_info)[3..5]);
	}
}
sub update_write {
	cse_alife_item::update_write(@_);
	if (($_[0]->{version} >= 118) && ($_[0]->{script_version} > 5)) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[0]);
	}
	if ($_[0]->{version} > 39) {
		$_[1]->pack_properties($_[0], (upd_properties_info)[1..6]);
	} else {
		$_[1]->pack_properties($_[0], (upd_properties_info)[9]);
		$_[1]->pack_properties($_[0], (upd_properties_info)[1]);
		$_[1]->pack_properties($_[0], (upd_properties_info)[7]);
		$_[1]->pack_properties($_[0], (upd_properties_info)[2]);
		$_[1]->pack_properties($_[0], (upd_properties_info)[8]);
		$_[1]->pack_properties($_[0], (upd_properties_info)[3..5]);
	}
}
sub update_import {
	cse_alife_item::update_import(@_);
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	cse_alife_item::update_export(@_);
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package cse_alife_item_weapon_magazined;
use strict;
use constant upd_properties_info => (
	{ name => 'upd:current_fire_mode', type => 'u8', default => 0 },
);
sub init {
	cse_alife_item_weapon::init(@_);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_item_weapon::state_read(@_);
}
sub state_write {
	cse_alife_item_weapon::state_write(@_);
}
sub state_import {
	cse_alife_item_weapon::state_import(@_);
}
sub state_export {
	cse_alife_item_weapon::state_export(@_);
}
sub update_read {
	cse_alife_item_weapon::update_read(@_);
	$_[1]->unpack_properties($_[0], upd_properties_info);
}
sub update_write {
	cse_alife_item_weapon::update_write(@_);
	$_[1]->pack_properties($_[0], upd_properties_info);
}
sub update_import {
	cse_alife_item_weapon::update_import(@_);
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	cse_alife_item_weapon::update_export(@_);
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package cse_alife_item_weapon_magazined_w_gl;
use strict;
use constant upd_properties_info => (
	{ name => 'upd:grenade_mode', type => 'u8', default => 0 },
);
sub init {
	cse_alife_item_weapon_magazined::init(@_);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_item_weapon::state_read(@_);
}
sub state_write {
	cse_alife_item_weapon::state_write(@_);
}
sub state_import {
	cse_alife_item_weapon_magazined::state_import(@_);
}
sub state_export {
	cse_alife_item_weapon_magazined::state_export(@_);
}
sub update_read {
	if ($_[0]->{version} >= 118) {
		$_[1]->unpack_properties($_[0], upd_properties_info);
	}
	cse_alife_item_weapon_magazined::update_read(@_);
}
sub update_write {	
	if ($_[0]->{version} >= 118) {
		$_[1]->pack_properties($_[0], upd_properties_info);
	}
	cse_alife_item_weapon_magazined::update_write(@_);
}
sub update_import {
	cse_alife_item_weapon_magazined::update_import(@_);
	if ($_[0]->{version} >= 118) {
		$_[1]->import_properties($_[2], $_[0], upd_properties_info);
	}
}
sub update_export {
	cse_alife_item_weapon_magazined::update_export(@_);
	if ($_[0]->{version} >= 118) {
		$_[1]->export_properties(undef, $_[0], upd_properties_info);
	}
}
#######################################################################
package cse_alife_item_weapon_shotgun;
use strict;
use constant upd_properties_info => (
	{ name => 'upd:ammo_ids', type => 'l8u8v', default => [0] },
);
sub init {
	cse_alife_item_weapon_magazined::init(@_);
	stkutils::entity::init_properties($_[0], upd_properties_info);
}
sub state_read {
	cse_alife_item_weapon::state_read(@_);
}
sub state_write {
	cse_alife_item_weapon::state_write(@_);
}
sub state_import {
	cse_alife_item_weapon_magazined::state_import(@_);
}
sub state_export {
	cse_alife_item_weapon_magazined::state_export(@_);
}
sub update_read {
	cse_alife_item_weapon_magazined::update_read(@_);
	$_[1]->unpack_properties($_[0], upd_properties_info);
}
sub update_write {
	cse_alife_item_weapon_magazined::update_write(@_);
	$_[1]->pack_properties($_[0], upd_properties_info);
}
sub update_import {
	cse_alife_item_weapon_magazined::update_import(@_);
	$_[1]->import_properties($_[2], $_[0], upd_properties_info);
}
sub update_export {
	cse_alife_item_weapon_magazined::update_export(@_);
	$_[1]->export_properties(undef, $_[0], upd_properties_info);
}
#######################################################################
package se_actor;
use strict;
use constant properties_info => (
	{ name => 'start_position_filled',	type => 'u8',	default => 0 },
	{ name => 'dumb',	type => 'actorData' , default => [0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,15,0,0,0,0,0,0,0,0,0,8,0,2,0,116,101,115,116,95,99,114,111,119,107,105,108,108,101,114,0,67,77,71,67,114,111,119,75,105,108,108,101,114,0,118,97,108,105,97,98,108,101,0,0,60,0,0,4,0,0,0,0,10,0,100,0,0,0,0,0,0,10,0,0,0,22,0,116,101,115,116,95,115,104,111,111,116,105,110,103,0,67,77,71,83,104,111,111,116,105,110,103,0,118,97,108,105,97,98,108,101,0,0,0,110,105,108,0,110,105,108,0,110,105,108,0,110,105,108,0,110,105,108,0,1,0,0,0,0,0,0,0,0,0,0,0,110,105,108,0,38,0,140,0,169,0] }, 
);
sub init {
	cse_alife_creature_actor::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_creature_actor::state_read(@_);
	if ($_[0]->{version} >= 128) {
		$_[0]->stkutils::entity::set_save_marker($_[1], 'load', 0, 'se_actor');
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
		$_[0]->stkutils::entity::set_save_marker($_[1], 'load', 1, 'se_actor');
	} elsif ($_[0]->{version} >= 122) {
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
	}
}
sub state_write {
	cse_alife_creature_actor::state_write(@_);
	if ($_[0]->{version} >= 128) {
		$_[0]->stkutils::entity::set_save_marker($_[1], 'save', 0, 'se_actor');
		$_[1]->pack_properties($_[0], (properties_info)[0]);
		$_[0]->stkutils::entity::set_save_marker($_[1], 'save', 1, 'se_actor');
	} elsif ($_[0]->{version} >= 122) {
		$_[1]->pack_properties($_[0], (properties_info)[1]);
	}
}
sub state_import {
	cse_alife_creature_actor::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_creature_actor::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_creature_actor::update_read(@_);
}
sub update_write {
	cse_alife_creature_actor::update_write(@_);
}
sub update_import {
	cse_alife_creature_actor::update_import(@_);
}
sub update_export {
	cse_alife_creature_actor::update_export(@_);
}
#######################################################################
package se_anomaly_field;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
	{ name => 'startup',		type => 'u8',	default => 1 },
	{ name => 'update_time_present',type => 'u8',	default => 0 },
	{ name => 'zone_count',		type => 'u8',	default => 0 },
);
sub init {
	cse_alife_space_restrictor::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_space_restrictor::state_read(@_);
$_[1]->resid() == 3 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[1]->resid() == 3', 'unexpected size');
	$_[1]->unpack_properties($_[0], (properties_info)[0]);
	$_[0]->{startup} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{startup} == 0', 'unexpected value');
	$_[1]->unpack_properties($_[0], (properties_info)[1]);
	$_[0]->{update_time_present} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{update_time_present} == 0', 'unexpected value');
	$_[1]->unpack_properties($_[0], (properties_info)[2]);
	$_[0]->{zone_count} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{zone_count} == 0', 'unexpected value');
}
sub state_write {
	cse_alife_space_restrictor::state_write(@_);
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	cse_alife_space_restrictor::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_space_restrictor::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package se_level_changer;
use strict;
use constant properties_info => (
	{ name => 'enabled',	type => 'u8',	default => 1 },
	{ name => 'hint',	type => 'sz',	default => 'level_changer_invitation' },
);
sub init {
	cse_alife_level_changer::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_level_changer::state_read(@_);
	if ($_[0]->{version} >= 124) {
		$_[0]->stkutils::entity::set_save_marker($_[1], 'load', 0, 'se_level_changer');
		$_[1]->unpack_properties($_[0], properties_info);
		$_[0]->stkutils::entity::set_save_marker($_[1], 'load', 1, 'se_level_changer');
	}
}
sub state_write {
	cse_alife_level_changer::state_write(@_);
	if ($_[0]->{version} >= 124) {
		$_[0]->stkutils::entity::set_save_marker($_[1], 'save', 0, 'se_level_changer');
		$_[1]->pack_properties($_[0], properties_info);
		$_[0]->stkutils::entity::set_save_marker($_[1], 'save', 1, 'se_level_changer');
	}
}
sub state_import {
	cse_alife_level_changer::state_import(@_);
	if ($_[0]->{version} >= 124) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_level_changer::state_export(@_);
	if ($_[0]->{version} >= 124) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
#######################################################################
package se_monster;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
	{ name => 'under_smart_terrain',	type => 'u8',	default => 0 },
	{ name => 'job_online',				type => 'u8',	default => 2 },
	{ name => 'job_online_condlist',	type => 'sz',	default => 'nil' },
	{ name => 'was_in_smart_terrain',	type => 'u8',	default => 0 },
	{ name => 'squad_id',				type => 'sz',	default => 'nil' },	
	{ name => 'sim_forced_online',		type => 'u8',	default => 0 },
	{ name => 'old_lvid',				type => 'sz',	default => 'nil' },	
	{ name => 'active_section',			type => 'sz',	default => 'nil' },	
	
);
sub init {
	cse_alife_monster_base::init(@_);
	cse_alife_monster_rat::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	if (($_[0]->{section_name} eq 'm_rat_e') && ($_[0]->{version} <= 104)) {
		cse_alife_monster_rat::state_read(@_);
	} else {
		cse_alife_monster_base::state_read(@_);
		if (defined $_[0]->{script_version}) {
			if ($_[0]->{script_version} > 10) {
				$_[1]->unpack_properties($_[0], (properties_info)[6..7]);
			} elsif ($_[0]->{script_version} > 3) {
				$_[1]->unpack_properties($_[0], (properties_info)[1]);
				if ($_[0]->{script_version} > 4) {
					if ($_[0]->{job_online} > 2) {
						$_[1]->unpack_properties($_[0], (properties_info)[2]);	
					}
					if ($_[0]->{script_version} > 6) {	
						$_[1]->unpack_properties($_[0], (properties_info)[4]);	
					} else {
						$_[1]->unpack_properties($_[0], (properties_info)[3]);	
					}
					if ($_[0]->{script_version} > 7) {
						$_[1]->unpack_properties($_[0], (properties_info)[5]);	
					}
				}
			} elsif ($_[0]->{script_version} == 2) {
				$_[1]->unpack_properties($_[0], (properties_info)[0]);
			}
		}
	}
}
sub state_write {
	if (($_[0]->{section_name} eq 'm_rat_e') && ($_[0]->{version} <= 104)) {
		cse_alife_monster_rat::state_write(@_);
	} else {
		cse_alife_monster_base::state_write(@_);
		if (defined $_[0]->{script_version}) {
			if ($_[0]->{script_version} > 10) {
				$_[1]->pack_properties($_[0], (properties_info)[6..7]);
			} elsif ($_[0]->{script_version} > 3) {
				$_[1]->pack_properties($_[0], (properties_info)[1]);
				if ($_[0]->{script_version} > 4) {
					if ($_[0]->{job_online} > 2) {
						$_[1]->pack_properties($_[0], (properties_info)[2]);	
					}
					if ($_[0]->{script_version} > 6) {	
						$_[1]->pack_properties($_[0], (properties_info)[4]);	
					} else {
						$_[1]->pack_properties($_[0], (properties_info)[3]);	
					}
					if ($_[0]->{script_version} > 7) {
						$_[1]->pack_properties($_[0], (properties_info)[5]);	
					}
				}
			} elsif ($_[0]->{script_version} == 2) {
				$_[1]->pack_properties($_[0], (properties_info)[0]);
			}
		}
	}
}
sub state_import {
	if (($_[0]->{section_name} eq 'm_rat_e') && ($_[0]->{version} <= 104)) {
		cse_alife_monster_rat::state_import(@_);
	} else {
		cse_alife_monster_base::state_import(@_);
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	if (($_[0]->{section_name} eq 'm_rat_e') && ($_[0]->{version} <= 104)) {
		cse_alife_monster_rat::state_export(@_);
	} else {
		cse_alife_monster_base::state_export(@_);
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
sub update_read {
	if (($_[0]->{section_name} eq 'm_rat_e') && ($_[0]->{version} <= 104)) {
		cse_alife_monster_rat::update_read(@_);
	} else {
		cse_alife_monster_base::update_read(@_);
	}
}
sub update_write {
	if (($_[0]->{section_name} eq 'm_rat_e') && ($_[0]->{version} <= 104)) {
		cse_alife_monster_rat::update_write(@_);
	} else {
		cse_alife_monster_base::update_write(@_);
	}
}
sub update_import {
	if (($_[0]->{section_name} eq 'm_rat_e') && ($_[0]->{version} <= 104)) {
		cse_alife_monster_rat::update_import(@_);
	} else {
		cse_alife_monster_base::update_import(@_);
	}
}
sub update_export {
	if (($_[0]->{section_name} eq 'm_rat_e') && ($_[0]->{version} <= 104)) {
		cse_alife_monster_rat::update_export(@_);
	} else {
		cse_alife_monster_base::update_export(@_);
	}
}
#######################################################################
package se_respawn;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
	{ name => 'spawned_obj', type => 'u8', default => 0 },
#	{ name => 'spawned_obj', type => 'l8u16v', default => [0] },		#this parameter is table really
);
sub init {
	cse_alife_smart_zone::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_smart_zone::state_read(@_);
	if ($_[0]->{version} >= 116) {
		$_[1]->resid() == 1 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[1]->resid() == 1', 'unexpected size');
		$_[1]->unpack_properties($_[0], properties_info);
	}
}
sub state_write {
	cse_alife_smart_zone::state_write(@_);
	if ($_[0]->{version} >= 116) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_smart_zone::state_import(@_);
	if ($_[0]->{version} >= 116) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_smart_zone::state_export(@_);
	if ($_[0]->{version} >= 116) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
#######################################################################
package se_sim_faction;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
	{ name => 'community_player', type => 'u8', default => 0  },
	{ name => 'start_position_filled', type => 'u8', default => 0  },
	{ name => 'current_expansion_level', type => 'u8', default => 0  },	
	{ name => 'last_spawn_time_marker', type => 'u8', default => 0 },	#{ name => 'last_spawn_time', type => 'u8v8' },		
	{ name => 'squad_target_cache_count', type => 'u8', default => 255  }, #next squad_target_cache collection
	{ name => 'random_tasks_count', type => 'u8', default => 0  }, #next random_tasks collection
	{ name => 'current_attack_quantity_count', type => 'u8', default => 0  }, #next current_attack_quantity collection
	{ name => 'squads_count', type => 'u16', default => 0  }, #next squads collection
	{ name => 'se_sim_faction__marker', type => 'u16', default => 9},
);
sub init {
	cse_alife_smart_zone::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_smart_zone::state_read(@_);
	if ($_[0]->{version} >= 122) {
		$_[1]->unpack_properties($_[0], (properties_info)[0..7]);
		$_[0]->{last_spawn_time_marker} == 255 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{last_spawn_time_marker} == 255', 'unexpected value');
		$_[0]->{squad_target_cache_count} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{squad_target_cache_count} == 0', 'unexpected value');
		$_[0]->{random_tasks_count} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{random_tasks_count} == 0', 'unexpected value');
		$_[0]->{current_attack_quantity_count} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{current_attack_quantity_count} == 0', 'unexpected value');
		$_[0]->{squads_count} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{squads_count} == 0', 'unexpected value');
		if ($_[0]->{version} >= 124) {
			$_[1]->unpack_properties($_[0], (properties_info)[8]);
		}
	}
}
sub state_write {
	cse_alife_smart_zone::state_write(@_);
	if ($_[0]->{version} >= 122) {
		$_[1]->pack_properties($_[0], (properties_info)[0..7]);
		if ($_[0]->{version} >= 124) {
			$_[1]->pack_properties($_[0], (properties_info)[8]);
		}
	}
}
sub state_import {
	cse_alife_smart_zone::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_smart_zone::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package se_smart_cover;
use strict;
use constant properties_info => (
	{ name => 'last_description',	type => 'sz',		default => '' },
	{ name => 'loopholes',		type => 'l8szbv',	default => [''] }
);
sub init {
	cse_smart_cover::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_smart_cover::state_read(@_);
	if ($_[0]->{version} >=128) {
		$_[1]->unpack_properties($_[0], properties_info);
	}
};
sub state_write {
	cse_smart_cover::state_write(@_);
	if ($_[0]->{version} >=128) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_smart_cover::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_smart_cover::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package se_smart_terrain;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
###SOC
	{ name => 'duration_end_present',	type => 'u8',	default => 0 },
	{ name => 'idle_end_present',		type => 'u8',	default => 0 },
	{ name => 'gulag_working',		type => 'u8',	default => 0 },
###CS	
	{ name => 'actor_defence_come',	type => 'u8',	default => 0 },	
	{ name => 'combat_quest',	type => 'sz',	default => 'nil' },		
	{ name => 'task',	type => 'u16',	default => 0xFFFF },	
	{ name => 'see_actor_enemy',	type => 'sz',	default => 'nil' },	
	{ name => 'flag',	type => 'u8',	default => 0 },	#next CTime
	{ name => 'squads_count',	type => 'u8',	default => 0 },	#next squads collection
	{ name => 'force_online',	type => 'u8',	default => 0 },
	{ name => 'force_online_squads_count',	type => 'u8',	default => 0 }, #next force_online_squads collection
	{ name => 'cover_manager_is_valid',	type => 'u8',	default => 0 },
	{ name => 'cover_manager_cover_table_count',	type => 'u8',	default => 0 }, #next cover_table collection
	{ name => 'se_smart_terrain_combat_manager_cover_manager__marker',	type => 'u16', default => 2}, 
	{ name => 'se_smart_terrain_combat_manager__marker',	type => 'u16', default => 19}, 
	{ name => 'npc_info_count',	type => 'u8',	default => 0 },	#next npc_info collection
	{ name => 'dead_time_count',	type => 'u8',	default => 0 },	#next dead_time collection
	{ name => 'se_smart_terrain__marker',	type => 'u16', default => 23}, 	
####COP
	{ name => 'arriving_npc_count',			type => 'u8',	default => 0 },
	{ name => 'base_on_actor_control_present',	type => 'u8',	default => 0 },
	{ name => 'is_respawn_point',	type => 'u8',	default => 0 },
	{ name => 'population',		type => 'u8',	default => 0 },

);
sub init {
	cse_alife_smart_zone::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_smart_zone::state_read(@_);
	if ($_[0]->{version} < 122) {
		$_[1]->unpack_properties($_[0], (properties_info)[0]);
		$_[0]->{duration_end_present} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{duration_end_present} == 0', 'unexpected value');
		$_[1]->unpack_properties($_[0], (properties_info)[1]);
		$_[0]->{idle_end_present} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{idle_end_present} == 0', 'unexpected value');
		$_[1]->unpack_properties($_[0], (properties_info)[2]);
		$_[0]->{gulag_working} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{gulag_working} == 0', 'unexpected value');
		if ($_[0]->{script_version} <= 2) {
			$_[1]->unpack_properties($_[0], (properties_info)[21]);
		}
	} elsif (($_[0]->{version} >= 122) && ($_[0]->{version} < 128)) {
		$_[1]->unpack_properties($_[0], (properties_info)[3..12]);
		if ($_[0]->{version} >= 124) {
			$_[1]->unpack_properties($_[0], (properties_info)[13..17]);
		} else {
			$_[1]->unpack_properties($_[0], (properties_info)[15..16]);
		}
	} else {
		$_[0]->stkutils::entity::set_save_marker($_[1], 'load', 0, 'se_smart_terrain');
		$_[1]->unpack_properties($_[0], (properties_info)[18]);
		$_[0]->{arriving_npc_count} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{arriving_npc_count} == 0', 'unexpected value');
		$_[1]->unpack_properties($_[0], (properties_info)[15]);
		$_[0]->{npc_info_count} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{npc_info_count} == 0', 'unexpected value');
		$_[1]->unpack_properties($_[0], (properties_info)[16]);
		$_[0]->{dead_time_count} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{dead_time_count} == 0', 'unexpected value');
		$_[1]->unpack_properties($_[0], (properties_info)[19]);
		$_[0]->{base_on_actor_control_present} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{base_on_actor_control_present} == 0', 'unexpected value');
		$_[1]->unpack_properties($_[0], (properties_info)[20]);
		$_[0]->{is_respawn_point} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{is_respawn_point} == 0', 'unexpected value');
		$_[1]->unpack_properties($_[0], (properties_info)[21]);
		$_[0]->stkutils::entity::set_save_marker($_[1], 'load', 1, 'se_smart_terrain');
	}
}
sub state_write {
	cse_alife_smart_zone::state_write(@_);
	if ($_[0]->{version} < 122) {
		$_[1]->pack_properties($_[0], (properties_info)[0..2]);
		if ($_[0]->{script_version} <= 2) {
			$_[1]->pack_properties($_[0], (properties_info)[21]);
		}
	} elsif (($_[0]->{version} >= 122) && ($_[0]->{version} < 128)) {
		$_[1]->pack_properties($_[0], (properties_info)[3..12]);
		if ($_[0]->{version} >= 124) {
			$_[1]->pack_properties($_[0], (properties_info)[13..17]);
		} else {
			$_[1]->pack_properties($_[0], (properties_info)[15..16]);
		}
	} else {
		$_[0]->stkutils::entity::set_save_marker($_[1], 'save', 0, 'se_smart_terrain');
		$_[1]->pack_properties($_[0], (properties_info)[18]);
		$_[1]->pack_properties($_[0], (properties_info)[15 .. 16]);
		$_[1]->pack_properties($_[0], (properties_info)[19 .. 21]);
		$_[0]->stkutils::entity::set_save_marker($_[1], 'save', 1, 'se_smart_terrain');
	}
}
sub state_import {
	cse_alife_smart_zone::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_smart_zone::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package se_stalker;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
	{ name => 'under_smart_terrain',	type => 'u8',	default => 0 },	
	{ name => 'job_online',			type => 'u8',	default => 2 },
	{ name => 'job_online_condlist',	type => 'sz',	default => 'nil' },
	{ name => 'was_in_smart_terrain',	type => 'u8',	default => 0 },
	{ name => 'death_dropped',		type => 'u8',	default => 0 },
	{ name => 'squad_id',		type => 'sz',	default => "nil" },
	{ name => 'sim_forced_online',	type => 'u8',	default => 0 },
	{ name => 'old_lvid',				type => 'sz',	default => 'nil' },	
	{ name => 'active_section',			type => 'sz',	default => 'nil' },	
);
sub init {
	cse_alife_human_stalker::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_human_stalker::state_read(@_);
	if (defined $_[0]->{script_version}) {
		if ($_[0]->{script_version} > 10) {
			$_[1]->unpack_properties($_[0], (properties_info)[7..8]);
			$_[1]->unpack_properties($_[0], (properties_info)[4]);
		} elsif ($_[0]->{script_version} > 2) {
			$_[1]->unpack_properties($_[0], (properties_info)[1]);
			if ($_[0]->{script_version} > 4) {
				if ($_[0]->{job_online} > 2) {
					$_[1]->unpack_properties($_[0], (properties_info)[2]);	
				}
				if ($_[0]->{script_version} > 6) {	
					$_[1]->unpack_properties($_[0], (properties_info)[4..5]);	
				} elsif ($_[0]->{script_version} > 5) {	
					$_[1]->unpack_properties($_[0], (properties_info)[3..4]);	
				} else {
					$_[1]->unpack_properties($_[0], (properties_info)[3]);	
				}
				if ($_[0]->{script_version} > 7) {
					$_[1]->unpack_properties($_[0], (properties_info)[6]);	
				}
			}
		} elsif ($_[0]->{script_version} == 2) {
			$_[1]->unpack_properties($_[0], (properties_info)[0]);
		}
	}
}
sub state_write {
	cse_alife_human_stalker::state_write(@_);
	if (defined $_[0]->{script_version}) {
		if ($_[0]->{script_version} > 10) {
			$_[1]->pack_properties($_[0], (properties_info)[7..8]);
			$_[1]->pack_properties($_[0], (properties_info)[4]);
		} elsif ($_[0]->{script_version} > 2) {
			$_[1]->pack_properties($_[0], (properties_info)[1]);
			if ($_[0]->{script_version} > 4) {
				if ($_[0]->{job_online} > 2) {
					$_[1]->pack_properties($_[0], (properties_info)[2]);	
				}
				if ($_[0]->{script_version} > 6) {	
					$_[1]->pack_properties($_[0], (properties_info)[4..5]);	
				} elsif ($_[0]->{script_version} > 5) {	
					$_[1]->pack_properties($_[0], (properties_info)[3..4]);	
				} else {
					$_[1]->pack_properties($_[0], (properties_info)[3]);	
				}
				if ($_[0]->{script_version} > 7) {
					$_[1]->pack_properties($_[0], (properties_info)[6]);	
				}
			}
		} elsif ($_[0]->{script_version} == 2) {
			$_[1]->pack_properties($_[0], (properties_info)[0]);
		}
	}
}
sub state_import {
	cse_alife_human_stalker::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_human_stalker::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
sub update_read {
	cse_alife_human_stalker::update_read(@_);
}
sub update_write {
	cse_alife_human_stalker::update_write(@_);
}
sub update_import {
	cse_alife_human_stalker::update_import(@_);
}
sub update_export {
	cse_alife_human_stalker::update_export(@_);
}
#######################################################################
package se_turret_mgun;
use strict;
use constant properties_info => (
	{ name => 'health', type => 'f32', default => 1.0 },
);
sub init {
	cse_alife_helicopter::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_helicopter::state_read(@_);
	$_[1]->unpack_properties($_[0], properties_info);
}
sub state_write {
	cse_alife_helicopter::state_write(@_);
	$_[1]->pack_properties($_[0], properties_info);
}
sub state_import {
	cse_alife_helicopter::state_import(@_);
	$_[1]->import_properties($_[2], $_[0], properties_info);
}
sub state_export {
	cse_alife_helicopter::state_export(@_);
	$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
}
#######################################################################
package se_zone_anom;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
	{ name => 'last_spawn_time_present', type => 'u8', default => 0 },
);
sub init {
	cse_alife_anomalous_zone::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_anomalous_zone::state_read(@_);
	return if (($_[0]->{version} < 128) && (substr($_[0]->{section_name}, 0, 10) eq 'zone_field'));
	if ($_[0]->{version} >= 118) {
		$_[1]->unpack_properties($_[0], properties_info);
		if (ref($_[0]) eq 'se_zone_anom') {
			$_[0]->{last_spawn_time_present} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{last_spawn_time_present} == 0', 'unexpected value');
		}
	}
}
sub state_write {
	cse_alife_anomalous_zone::state_write(@_);
	return if (($_[0]->{version} < 128) && (substr($_[0]->{section_name}, 0, 10) eq 'zone_field'));
	if ($_[0]->{version} >= 118) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_anomalous_zone::state_import(@_);
	return if (($_[0]->{version} < 128) && (substr($_[0]->{section_name}, 0, 10) eq 'zone_field'));
	if ($_[0]->{version} >= 118) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_anomalous_zone::state_export(@_);
	return if (($_[0]->{version} < 128) && (substr($_[0]->{section_name}, 0, 10) eq 'zone_field'));
	if ($_[0]->{version} >= 118) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
sub update_read {
	cse_alife_anomalous_zone::update_read(@_);
}
sub update_write {
	cse_alife_anomalous_zone::update_write(@_);
}
sub update_import {
	cse_alife_anomalous_zone::update_import(@_);
}
sub update_export {
	cse_alife_anomalous_zone::update_export(@_);
}
#######################################################################
package se_zone_visual;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
	{ name => 'last_spawn_time_present', type => 'u8', default => 0 },
);
sub init {
	cse_alife_zone_visual::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_zone_visual::state_read(@_);
	if ($_[0]->{version} >= 118) {
	$_[1]->resid() == 1 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[1]->resid() == 1', 'unexpected size');
		$_[1]->unpack_properties($_[0], properties_info);
		$_[0]->{last_spawn_time_present} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{last_spawn_time_present} == 0', 'unexpected value');
	}
}
sub state_write {
	cse_alife_zone_visual::state_write(@_);
	if ($_[0]->{version} >= 118) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_zone_visual::state_import(@_);
	if ($_[0]->{version} >= 118) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_zone_visual::state_export(@_);
	if ($_[0]->{version} >= 118) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
sub update_read {
	cse_alife_zone_visual::update_read(@_);
}
sub update_write {
	cse_alife_zone_visual::update_write(@_);
}
sub update_import {
	cse_alife_zone_visual::update_import(@_);
}
sub update_export {
	cse_alife_zone_visual::update_export(@_);
}
#######################################################################
package se_zone_torrid;
use strict;
use stkutils::debug 'fail';
use constant properties_info => (
	{ name => 'last_spawn_time_present', type => 'u8', default => 0 },
);
sub init {
	cse_alife_torrid_zone::init(@_);
	stkutils::entity::init_properties($_[0], properties_info);
}
sub state_read {
	cse_alife_torrid_zone::state_read(@_);
	if ($_[0]->{version} >= 128) {
		$_[1]->unpack_properties($_[0], properties_info);
		$_[0]->{last_spawn_time_present} == 0 or fail(__PACKAGE__.'::state_read', __LINE__, '$_[0]->{last_spawn_time_present} == 0', 'unexpected value');
	}
}
sub state_write {
	cse_alife_torrid_zone::state_write(@_);
	if ($_[0]->{version} >= 128) {
		$_[1]->pack_properties($_[0], properties_info);
	}
}
sub state_import {
	cse_alife_torrid_zone::state_import(@_);
	if ($_[0]->{version} >= 128) {
		$_[1]->import_properties($_[2], $_[0], properties_info);
	}
}
sub state_export {
	cse_alife_torrid_zone::state_export(@_);
	if ($_[0]->{version} >= 128) {
		$_[1]->export_properties(__PACKAGE__, $_[0], properties_info);
	}
}
sub update_read {
	cse_alife_torrid_zone::update_read(@_);
}
sub update_write {
	cse_alife_torrid_zone::update_write(@_);
}
sub update_import {
	cse_alife_torrid_zone::update_import(@_);
}
sub update_export {
	cse_alife_torrid_zone::update_export(@_);
}
#######################################################################
1;