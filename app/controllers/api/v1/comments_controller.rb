module Api
	module V1
		class CommentsController < ApplicationController
			skip_before_action :verify_authenticity_token

			def create
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end	
				comment = Comment.new(comment_params)
				if current_user
					submission = Submission.where("id = ?" , params[:id])
					if submission.empty?
						render json: {status: 'ERROR', message: 'Submission does not exist', data: nil}, :status => 404
					else
						if !comment_params[:content].blank?
							comment.user = current_user
							submission = Submission.find(params[:id])
							comment.submission = submission
							if comment.save
								comment.vote_by :voter => current_user
								render json: {status: 'SUCCESS', message: 'Comment created correctly', data: comment}, status: :ok
							else
								render json: {status: 'ERROR', message: 'Error in data base', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'Comment can not be blank', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, :status => 403
				end
			end

			def vote
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end	
				if current_user
					comment = Comment.where("id = ?" , params[:id])
					if comment.empty?
						render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
					else				
						comment = Comment.find(params[:id])
						if !current_user.voted_for?(comment)
							comment.liked_by current_user
							render json: {status: 'SUCCESS', message: 'Vote saved', data: 
								[{"votes": comment.get_upvotes.size}]}, status: :ok
						else
							render json: {status: 'ERROR', message: 'User has already voted this comment', data: nil}, status: :unprocessable_entity
						end
					end
				else 
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, 
							:status => 403
				end
			end

			def unvote
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				if current_user
					comment = Comment.where("id = ?" , params[:id])
					if comment.empty?
						render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
					else
						comment = Comment.find(params[:id])
						if current_user.voted_for?(comment)
							if current_user.id != comment.user.id
								comment.unliked_by current_user
								render json: {status: 'SUCCESS', message: 'Unvote saved', data: 
									[{"votes": comment.get_upvotes.size}]}, status: :ok
							else
								render json: {status: 'ERROR', message: 'User cannot unvote its own comment', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'User has already unvoted this comment', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, 
								:status => 403
				end
			end

			def update
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				if current_user
					comment = Comment.where("id = ?", params[:id])
					if comment.empty?
						render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
					else
						comment = Comment.find(params[:id])
						if current_user.id == comment.user.id
							comment.update(comment_params)
							commentResponse = {
								id: comment.id,
								user_id: comment.user.id,
								submission_id: comment.submission.id,
								content: comment.content,
								created_at: comment.created_at,
								updated_at: comment.updated_at
							}
							render json: {status: 'SUCCESS', message: 'Comment updated correctly', data: commentResponse}, status: :ok
						else
							render json: {status: 'ERROR', message: 'Can not update someones comment', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, :status => 403
				end
			end

			def submission_comments
				submission = Submission.where("id = ?", params[:id])
				if submission.empty?
					render json: {status: 'ERROR', message: 'Submission does not exist', data: nil}, :status => 404
				else
					comments = Comment.where("submission_id=?", params[:id]).order("created_at DESC")
					render json: {status: 'SUCCESS', message: 'Comments from submission', data: comments}, status: :ok
				end
			end

			def threads
				user = User.where("id = ?", params[:id])
				if user.empty?
					render json: {status: 'ERROR', message: 'User does not exist', data: nil}, :status => 404
				else
					comments = Comment.where("user_id=?", params[:id]).order("created_at DESC")
					replies = Reply.where("user_id=?", params[:id]).order("created_at DESC")
					render json: {status: 'SUCCESS', message: 'User comments', data: comments+replies}, status: :ok
				end
      		end

			def comment
				comment = Comment.where("id = ?", params[:id])
				if comment.empty?
					render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
				else
					comment = Comment.find(params[:id])
					   render json: {status: 'SUCCESS', message: 'Comment', data: comment}, status: :ok
				end
      		end

      		def destroy
      			current_user = nil
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				if current_user
					if Comment.where(id: params[:id]).present?
						comment = Comment.find(params[:id])
						if comment.user_id == current_user.id
							comment.reply.each do |child_reply|
								delete_replies(child_reply)
							end
							
							if comment.destroy
						        render json: {status: 'SUCCESS', message: 'Comment deleted', data: nil},
									status: :ok
					    	else
					    		render json: {status: 'ERROR', message: 'Comment not deleted', data: nil}, 
									:status => 500
					    	end
					    else
					    	render json: {status: 'ERROR', message: 'Cannot delete others comments', data: nil}, 
							:status => 403
					    end
				    else
				    	render json: {status: 'ERROR', message: 'Comment does not exists', data: nil}, 
								status: :unprocessable_entity
				    end
				else
			    	render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, 
							:status => 403
		    	end
			end
			
			def delete_replies(reply)
				if(reply.child_replies.size == 0)
					reply.destroy
					return
				end
				reply.child_replies.each do |child_reply|
					delete_replies(child_reply)
				end
				reply.destroy
			end
      			
			def comment_params
				params.require(:comment).permit(:content, :submission_id)
			end

		end
	end
end