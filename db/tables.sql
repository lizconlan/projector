create table `projects` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(256) NOT NULL,
  `readme` text NOT NULL,
  `date` datetime NULL,
  `slug` varchar(128) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table `repositories` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(256) NOT NULL,
  `url` varchar(256) NOT NULL,
  `notes` text NULL,
  `project_id` int(11) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

create table `live_sites` (
  `id` int(11) NOT NULL auto_increment,
  `url` varchar(256) NOT NULL,
  `notes` text NULL,
  `project_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;