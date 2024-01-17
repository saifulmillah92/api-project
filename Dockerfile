# Use an official Ruby runtime as a parent image
FROM ruby:3.0.0

# Set the working directory in the container
WORKDIR /app

# Copy Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install any needed packages specified in your Gemfile
RUN bundle install

# Copy the rest of the application code into the container
COPY . .

# Make port 3000 available to the world outside this container
EXPOSE 3000

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]
