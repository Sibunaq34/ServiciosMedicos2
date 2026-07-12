<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'serviciosword' );

/** Database username */
define( 'DB_USER', 'sitios' );

/** Database password */
define( 'DB_PASSWORD', 'Sitios1234.' );

/** Database hostname */
define( 'DB_HOST', 'localhost:3307' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '3bvk~xii2o/ !LrJLn-0__m)-)/$BDgWmS!P qzSh@RT^pC9zaryx=Y9v#cxu[}j' );
define( 'SECURE_AUTH_KEY',  '{@<;zqoF*]NRGzwyOm[mPN`D#F51&QkMWJ5.}J`!<1#Zq29g|mtcmOYgAy@jwVD(' );
define( 'LOGGED_IN_KEY',    '8`<MD*d8axGBN2n=Zf:*}%<Ie(eSwp)1gM->tb7P;IIj*k}`IqXaXgjbfnO:@/$n' );
define( 'NONCE_KEY',        't?j>}rE_-nl)69+:02w)TA]gXh@g`yLb9&RHe|_Aqk>7A>_YbEmI[sdO2MqD_lU^' );
define( 'AUTH_SALT',        'vt7OlGXmWlf/aZVZt7%+%R)s=V*z|B!+V6wjuUNNHJVuPE({6Bs6E3Dv|*SgY7@)' );
define( 'SECURE_AUTH_SALT', '8xS`V5dm9cmKNMEF(Vw`y6!BD7P~pxwipf2cC1B}j7ZhEDF@Zg><0UhA4,X=XF@D' );
define( 'LOGGED_IN_SALT',   'eE#~aU/x F+/n6n4/SHD[NubQV{Z4,5xcRn|$=FN+@=05emg_VjXAiMBd|P]ec1$' );
define( 'NONCE_SALT',       'F(PoQl7Q>II#A_`X$H%h[WK*<^[+10S4jEouCDp<poxNM,-k>T}v6?+qX;K ak3M' );

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
