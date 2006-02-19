/* SmoothWall install program.
 *
 * This program is distributed under the terms of the GNU General Public
 * Licence.  See the file COPYING for details.
 *
 * (c) Lawrence Manning, 2001
 * Main include file.
 * 
 * $Id: install.h,v 1.10 2004/02/24 21:24:10 alanh Exp $
 * 
 */

#include "../libsmooth/libsmooth.h"

#define IDE_EMPTY 0
#define IDE_CDROM 1
#define IDE_HD 2
#define IDE_UNKNOWN 3

/* CDROMS and harddisks. */
struct devparams
{
	char devnode[STRING_SIZE];
	int module;
	char modulename[STRING_SIZE];
	char options[STRING_SIZE];
};

/* ide.c */
int checkide(char letter);
char findidetype(int type);

/* cdrom.c */
int ejectcdrom(char *dev);

/* nic.c */
int networkmenu(struct keyvalue *ethernetkv);

/* net.c */
int checktarball(char *);

/* config.c */
int write_disk_configs(struct devparams *dp);
int write_lang_configs( char *lang);
int write_ethernet_configs(struct keyvalue *ethernetkv);

/* pcmcia.c */
char * initialize_pcmcia (void);

/* upgrade_v12_v13.c */
int upgrade_v12_v13();

/* upgrade_v130_v131.c */
int upgrade_v130_v140();

/* usb.c */
int initialize_usb();
int write_usb_modules_conf();

/* scsi.c */
int try_scsi(char *dev);
int get_boot(char *dev);
