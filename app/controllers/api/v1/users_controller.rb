class Api::V1::UsersController < ApplicationController

  before_action :set_user

  def profile_image
    # Extract the content type and base64 encoded string from the data URL
    content_type, encoded_img = params[:image].match(/\Adata:(.*?);base64,(.*)\z/).captures
    decoded_image = Base64.decode64(encoded_img)

    # Check the file size (in bytes), and return an error if it's larger than 5 MB
    if decoded_image.size > 5.megabytes
      render json: { message: "Image size must not exceed 5 MB." }, status: :unprocessable_entity
      return
    end

    # Determine the file extension based on the content type
    extension = content_type.split('/').last

    tempfile = Tempfile.new(['profile_image', ".#{extension}"])
    tempfile.binmode
    tempfile.write(decoded_image)
    tempfile.rewind

    # Use MiniMagick to resize the image
    image = MiniMagick::Image.new(tempfile.path)
    image.resize "200x200"
    image.write tempfile.path

    uploaded_image = ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: "profile_image.#{extension}",
      content_type: content_type
    )

    @user.profile_image.attach(uploaded_image)
    if @user.save
      render json: UserBlueprint.render_as_hash(@user, view: :restricted), status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end

    # Ensure to close and unlink (delete) the tempfile
    tempfile.close
    tempfile.unlink
  end

  private

  def set_user
    @user = @api_user
  end
end