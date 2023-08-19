class Api::V1::ReviewsController < ApplicationController
  before_action :set_user
  before_action :set_review, only: [:update, :destroy]
  skip_before_action :authenticate_from_token!, only: [:index]

  # GET /users/:user_id/reviews
  def index
    render json: @user.reviews_received, status: :ok
  end

  # POST /users/:user_id/reviews
  def create
    @review = Review.new(review_params)
    @review.user = @api_user
    @review.reviewee = @user

    if @review.save
      render json: @review, status: :created
    else
      render json: { error: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:user_id/reviews/:id
  def update
    if @review.update(review_params)
      redirect_to user_reviews_path(@user), notice: 'Review was successfully updated.'
    else
      render json: { error: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:user_id/reviews/:id
  def destroy
    @review.destroy
    redirect_to user_reviews_path(@user), notice: 'Review was successfully deleted.'
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_review
    @review = Review.find(params[:id])
    # Consider adding an authorization check here to ensure users can only edit/delete their own reviews
  end

  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
