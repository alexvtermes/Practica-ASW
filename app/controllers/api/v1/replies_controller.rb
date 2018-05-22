module Api
	module V1
		class RepliesController < ApplicationController
			skip_before_action :verify_authenticity_token

			# Comments replies 
			def create
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end	
				reply = Reply.new(reply_params)
				if current_user
					replyorcomment = Comment.where("id = ?", params[:id]).first
					#replyorcomment = Reply.where("id = ?", params[:id])
					if replyorcomment.nil?
						render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
					else
						if !reply_params[:content].blank?
							#puts replyorcomment.inspect
							reply.comment = replyorcomment
							reply.user = current_user
							reply.submission = replyorcomment.submission

							if reply.save
								reply.vote_by :voter => current_user
								render json: {status: 'SUCCESS', message: 'Reply created correctly', data: reply}, status: :ok
							else
								render json: {status: 'ERROR', message: 'Error in data base', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'Reply can not be blank', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, :status => 403
				end
			end

			# Replies reply
			def create_reply
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end	
				reply = Reply.new(reply_params)
				if current_user
					replyorcomment = Reply.where("id = ?", params[:id]).first
					#replyorcomment = Reply.where("id = ?", params[:id])
					if replyorcomment.nil?
						render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
					else
						if !reply_params[:content].blank?
							#puts replyorcomment.inspect
							reply.parent = replyorcomment
							reply.user = current_user
							reply.submission = replyorcomment.submission

							if reply.save
								reply.vote_by :voter => current_user
								render json: {status: 'SUCCESS', message: 'Reply created correctly', data: reply}, status: :ok
							else
								render json: {status: 'ERROR', message: 'Error in data base', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'Reply can not be blank', data: nil}, status: :unprocessable_entity
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
					reply = Reply.where("id = ?" , params[:id]).first
					if reply.nil?
						render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
					else				
						if !current_user.voted_for?(reply)
							reply.liked_by current_user
							render json: {status: 'SUCCESS', message: 'Vote saved', data: 
								[{"votes": reply.get_upvotes.size}]}, status: :ok
						else
							render json: {status: 'ERROR', message: 'User has already voted this reply', data: nil}, status: :unprocessable_entity
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
					reply = Reply.where("id = ?" , params[:id]).first
					if reply.nil?
						render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
					else
						reply = Reply.find(params[:id])
						if current_user.voted_for?(reply)
							if current_user.id != reply.user.id
								reply.unliked_by current_user
								render json: {status: 'SUCCESS', message: 'Unvote saved', data: 
									[{"votes": reply.get_upvotes.size}]}, status: :ok
							else
								render json: {status: 'ERROR', message: 'User cannot unvote its own reply', data: nil}, status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'User has already unvoted this reply', data: nil}, status: :unprocessable_entity
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
					reply = Reply.where("id = ?", params[:id]).first
					puts reply.inspect
					if reply.nil?
						render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
					else
						if current_user.id == reply.user.id
							reply.update(reply_params)
							if !reply.comment.nil?
								replyResponse = {
									id: reply.id,
									user_id: reply.user.id,
									submission_id: reply.submission.id,
									content: reply.content,
									reply_parent_id: nil,
									comment_id: reply.comment.id,
									created_at: reply.created_at,
									updated_at: reply.updated_at
								}
							else
								replyResponse = {
									id: reply.id,
									user_id: reply.user.id,
									submission_id: reply.submission.id,
									content: reply.content,
									reply_parent_id: reply.parent.id,
									comment_id: nil,
									created_at: reply.created_at,
									updated_at: reply.updated_at
								}
							end
							
							render json: {status: 'SUCCESS', message: 'Reply updated correctly', data: replyResponse}, status: :ok
						else
							render json: {status: 'ERROR', message: 'Can not update someones reply', data: nil}, status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, :status => 403
				end
			end

			def comment_replies
				comment = Comment.where("id = ?", params[:id]).first
				if comment.nil?
					render json: {status: 'ERROR', message: 'Comment does not exist', data: nil}, :status => 404
				else
					replies = Reply.where("comment_id=?", params[:id]).order("created_at DESC")
					render json: {status: 'SUCCESS', message: 'Replies from comment', data: replies}, status: :ok
				end
			end

			def replies_replies
				reply = Reply.where("id = ?", params[:id]).first
				if reply.nil?
					render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
				else
					replies = Reply.where("reply_parent_id=?", params[:id]).order("created_at DESC")
					render json: {status: 'SUCCESS', message: 'Replies from comment', data: replies}, status: :ok
				end
			end

			def reply
				reply = Reply.where("id = ?", params[:id]).first
				if reply.nil?
					render json: {status: 'ERROR', message: 'Reply does not exist', data: nil}, :status => 404
				else
					   render json: {status: 'SUCCESS', message: 'Comment', data: reply}, status: :ok
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
				  if Reply.where(id: params[:id]).present?
					  reply = Reply.find(params[:id])
					  if reply.user_id == current_user.id
						  if reply.destroy
							  render json: {status: 'SUCCESS', message: 'Reply deleted', data: nil},
							  	status: :ok
						  else
							  render json: {status: 'ERROR', message: 'Reply not deleted', data: nil}, 
								  :status => 500
						  end
					  else
						  render json: {status: 'ERROR', message: 'Cannot delete others replies', data: nil}, 
						  :status => 403
					  end
				  else
					  render json: {status: 'ERROR', message: 'Reply does not exists', data: nil}, 
							  status: :unprocessable_entity
				  end
			  else
				  render json: {status: 'ERROR', message: 'Error in authenticity', data: nil}, 
						  :status => 403
			  end
		  	end
			  
			def reply_params
				params.require(:reply).permit(:content, :submission_id, :reply_parent_id)
			end

		end
	end
end