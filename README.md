# WordPress Docker Stack

My favourite Docker stack for WordPress.

## Setup steps

1. Copy example.env to .env and make your changes
1. [Add your certificates for SSL]
1. Build the Docker image: `docker build -t [image name]:latest .`
1. Add the name of this image to docker-compose.yml for the web container (line #31)
1. Add the local hostname to docker-compose.yml (line #37, #41)
1. Update the name, description and homepage in composer.json with your own
1. Start Docker: `make docker-up`
1. Install Composer dependencies (including WordPress Core): `make composer-i [local|prod]`
1. Initialise the environment: `make init [local|prod]`
1. Install WordPress (in the database) via the browser with the famous 5-minute install
1. Clean-up files, plugins & themes: `make clean-up [local|prod]`