<?php
// phpcs:ignoreFile

// Composer autoload.
require_once __DIR__ . '/../vendor/autoload.php';
// Dotenv load.
$dotenv = Dotenv\Dotenv::createImmutable( __DIR__ . '/../' );
$dotenv->safeLoad();
$dotenv->required( [ 'WP_TABLE_PREFIX', 'WP_HOME', 'WP_SITEURL' ] );

$table_prefix = $_ENV['WP_TABLE_PREFIX'];
$wp_home      = $_ENV['WP_HOME'];
$wp_siteurl   = $_ENV['WP_SITEURL'];
$db_name      = $_ENV['WP_DB_NAME'];
$db_user      = $_ENV['WP_DB_USER'];
$db_password  = $_ENV['WP_DB_PASSWORD'];
$db_host      = $_ENV['WP_DB_HOST'];

define( 'WP_HOME', $wp_home );
define( 'SITE_URL', $wp_siteurl );
define( 'DB_NAME', $db_name );
define( 'DB_USER', $db_user );
define( 'DB_PASSWORD', $db_password );
define( 'DB_HOST', $db_host );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY', 'put your unique phrase here' );
define( 'SECURE_AUTH_KEY', 'put your unique phrase here' );
define( 'LOGGED_IN_KEY', 'put your unique phrase here' );
define( 'NONCE_KEY', 'put your unique phrase here' );
define( 'AUTH_SALT', 'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT', 'put your unique phrase here' );
define( 'NONCE_SALT', 'put your unique phrase here' );

if ( isset( $_ENV['WP_DEBUG'] )
    && strtolower($_ENV['WP_DEBUG']) == 'true' ) {
    define( 'WP_DEBUG', true );
    define( 'WP_DEBUG_LOG', '/var/www/html/app/wp-content/uploads/debug.log' );
    define( 'SCRIPT_DEBUG', true );
    define( 'WP_DEBUG_DISPLAY', true );
    define( 'DISALLOW_FILE_EDIT', false );
} else {
    define( 'WP_DEBUG', false );
}

define( 'DISABLE_WP_CRON', true );


/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
