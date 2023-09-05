# Use the official Ruby image
FROM ruby:3.1.3

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set the working directory inside the container
WORKDIR /helping-pixies

# Copy the Gemfile and Gemfile.lock into the working directory
COPY Gemfile* /helping-pixies/

# Install gem dependencies
RUN bundle install

# Copy the current directory contents into the container at /myapi
COPY . /helping-pixies

# Expose port 3000 to the Docker host, so you can access it from the outside.
EXPOSE 3000

# Default command to execute on container start
CMD ["rails", "server", "-b", "0.0.0.0"]
