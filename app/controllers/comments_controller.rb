class CommentsController < ApplicationController
    before_action :set_comment, only: [:show, :edit, :update, :destroy]
    
    def vote
      if current_user
        @comment = Comment.find(params[:id])
        @comment.liked_by current_user
        redirect_to "/submissions/" + @comment.submission_id.to_s
      else
        redirect_to "/auth/google_oauth2"
      end
    end

    def unvote
      if current_user
        @comment = Comment.find(params[:id])
        @comment.unliked_by current_user
        redirect_to "/submissions/" + @comment.submission_id.to_s
      else
        redirect_to "/auth/google_oauth2"
      end
    end
    
    def new_reply
      if current_user
        @comment = Comment.find(params[:id])
        @replies = Reply.where("comment_id=?",@comment.id).order("created_at DESC")
      else
        redirect_to "/auth/google_oauth2"
      end
    end
    
    def threads
      @pre = Comment.all.order("created_at DESC") | Reply.all.order("created_at DESC");
      @commentsandreplies = @pre.sort_by { |t| t.created_at }.reverse!;
      render :threads
    end
    
    def user_comments
      begin
        @user = User.find(params[:user])
        @comments = Comment.where("user_id=?", params[:user]).order("created_at DESC")
      rescue ActiveRecord::RecordNotFound
        render :json => { "code" => "404", "message" => "User not found."}, status: :not_found
      end
    end
    
    def submission_comments
      begin
        @comments = Comment.where("submission_id=?", params[:id]).order("created_at DESC")
      rescue ActiveRecord::RecordNotFound
        render :json => { "code" => "404", "message" => "Submission not found."}, status: :not_found
      end
    end
  
    # GET /comments
    # GET /comments.json
    def index
      @comments = Comment.all
    end
  
    # GET /comments/1
    # GET /comments/1.json
    def show
    end
  
    # GET /comments/new
    def new
      @comment = Comment.new
    end
  
    # GET /comments/1/edit
    def edit
    end
  
    # POST /comments
    # POST /comments.json
    def create
      if current_user && !comment_params[:content].blank?
        @comment = Comment.new(comment_params)
        @comment.user = current_user
        
        respond_to do |format|
          if @comment.save
            @comment.vote_by :voter => current_user
            format.html { redirect_to @comment.submission }
            format.json { render :show, status: :created, location: @comment }
          else
            format.html { redirect_to @comment.submission, notice: 'Comment not created, you have to fill de field content' }
            format.json { render json: @comment.errors, status: :unprocessable_entity }
          end
        end
      elsif !current_user
        redirect_to "/auth/google_oauth2"
      else !current_user && comment_params[:content].blank?
        redirect_to "/submissions/" + comment_params[:submission_id], :notice => "Write a comment"       
      end
    end
  
    # PATCH/PUT /comments/1
    # PATCH/PUT /comments/1.json
    def update
      respond_to do |format|
        if @comment.update(comment_params)
          format.html { redirect_to @comment.submission }
          format.json { render :show, status: :ok, location: @comment }
        else
          format.html { render :edit }
          format.json { render json: @comment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /comments/1
    # DELETE /comments/1.json
    def destroy
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to comments_url }
        format.json { head :no_content }
      end
    end
  
    private

    def set_comment
        @comment = Comment.find(params[:id])
      end
  
      def comment_params
        params.require(:comment).permit(:content, :user_id, :submission_id)
      end
  end
  