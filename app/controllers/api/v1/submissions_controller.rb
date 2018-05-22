module Api
	module V1
		class SubmissionsController < ApplicationController
			skip_before_action :verify_authenticity_token

			def allJson(submissions)
				response = []
				submissions.each do |submission|
					comment_size = Comment.where('submission_id = ?', submission.id).length
					if submission.url != ""
						subResponse = {
							id: submission.id,
							user_creator_id: submission.user_id,
							created_at: submission.created_at,
							title: submission.title,
							url: submission.url,
							user_name: submission.user.name,
							comments: comment_size,
							votes: submission.cached_votes_total
						}
						response.push(subResponse)
					else
						subResponse = {
							id: submission.id,
							user_creator_id: submission.user_id,
							created_at: submission.created_at,
							title: submission.title,
							text: submission.text,
							user_name: submission.user.name,
							comments: comment_size,
							votes: submission.cached_votes_total
						}
						response.push(subResponse)
					end
				end
				return response
			end

			def all
				submissions = Submission.all.order("created_at DESC")
				response = allJson(submissions)
				render json: {status: 'SUCCESS', message: 'Submissions', data: response}, status: :ok
			end

			def urlJson(submissions)
				response = []
				submissions.each do |submission|
					comment_size = Comment.where('submission_id = ?', submission.id).length
					subResponse = {
						id: submission.id,
						user_creator_id: submission.user_id,
						created_at: submission.created_at,
						title: submission.title,
						url: submission.url,
						user_name: submission.user.name,
						comments: comment_size,
						votes: submission.cached_votes_total
					}
					response.push(subResponse)
				end
				return response
			end

			def url
				submissions = Submission.all.where.not(url:"").order(:cached_votes_total=> :desc)
				response = urlJson(submissions)
				render json: {status: 'SUCCESS', message: 'URL submissions', data: response}, status: :ok
			end

			def askJson(submissions)
				response = []
				submissions.each do |submission|
					comment_size = Comment.where('submission_id = ?', submission.id).length
					subResponse = {
						id: submission.id,
						user_creator_id: submission.user_id,
						created_at: submission.created_at,
						title: submission.title,
						text: submission.text,
						user_name: submission.user.name,
						comments: comment_size,
						votes: submission.cached_votes_total
					}
					response.push(subResponse)
				end
				return response
			end

			def ask
				submissions = Submission.all.where(url:"").order("created_at DESC")
				response = askJson(submissions)
				render json: {status: 'SUCCESS', message: 'ASK submissions', data: response}, status: :ok
			end

			def showJson(submission)
				response = []
				comment_size = Comment.where('submission_id = ?', submission.id).length
				if submission.url != ""
					subResponse = {
						id: submission.id,
						created_at: submission.created_at,
						user_creator_id: submission.user_id,
						title: submission.title,
						url: submission.url,
						user_name: submission.user.name,
						comments: comment_size,
						votes: submission.cached_votes_total
					}
					response.push(subResponse)
				else
					subResponse = {
						id: submission.id,
						created_at: submission.created_at,
						user_creator_id: submission.user_id,
						title: submission.title,
						text: submission.text,
						user_name: submission.user.name,
						comments: comment_size,
						votes: submission.cached_votes_total
					}
					response.push(subResponse)
				end
				return response
			end

			def show
				submission = Submission.where("id = ? ", params[:id])
				if submission.empty?
					render json: {status: 'ERROR', message: 'Submission does not exist', data: nil}, :status => 404
				else
					submission = Submission.find(params[:id])
					response = showJson(submission)
					render json: {status: 'SUCCESS', message: 'Submission', data: response}, status: :ok
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
					submission = Submission.where("id = ?", params[:id])
					if submission.empty?
						render json: {status: 'ERROR', message: 'Submission does not exist', data: {}}, :status => 404
					else
						submission = Submission.find(params[:id])
						if !current_user.voted_for?(submission)
							submission.liked_by current_user
							render json: {status: 'SUCCESS', message: 'Vote saved', data:
								[{"Votes": submission.get_upvotes.size}]}, status: :ok
						else
							render json: {status: 'ERROR', message: 'User has voted previously', data: nil},
								status: :unprocessable_entity
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
					submission = Submission.where("id = ?", params[:id])
					if submission.empty?
						render json: {status: 'ERROR', message: 'Submission does not exist', data: {}}, status: :unprocessable_entity
					else
						submission = Submission.find(params[:id])
						if current_user.voted_for?(submission)
							if current_user.id != submission.user.id
								submission.unliked_by current_user
								render json: {status: 'SUCCESS', message: 'Unvote saved', data:
									[{"Votes": submission.get_upvotes.size}]}, status: :ok
							else
								render json: {status: 'ERROR', message: 'User cannot unvote its own submission', data: nil},
								status: :unprocessable_entity
							end
						else
							render json: {status: 'ERROR', message: 'User has not voted previously', data: nil},
								status: :unprocessable_entity
						end
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil},
						:status => 403
				end
			end

			def xor(a, b)
			   	(a and (not b)) or ((not a) and b)
			end

			def new
				@submission = Submission.new
			end

			def create
				current_user = nil
				begin
					user = User.where(:api_key => request.headers['Authorization']).first
					if user
						current_user = user
					end
				rescue Exception => e
					#empty
				end
				submission = Submission.new(submission_params)
				if current_user
				    if xor(submission_params[:url].blank?, submission_params[:text].blank?) && !submission_params[:title].blank?
				      	parameters = submission_params
				      	if submission_params[:text].blank?
				          	parameters[:url] = parameters[:url].sub(/^https?\:\/\//, '').sub(/^www./,'')
				          	parameters[:url] = 'http://' + parameters[:url]
				        end
				        if (parameters[:url] != "" && !Submission.where(url: parameters[:url]).present?) ||
				          (parameters[:url] == "")
							submission = Submission.new(parameters)
							submission.user = current_user
					        subuser = submission.user
					        subuser.karma = subuser.karma + 1
							if submission.save && subuser.save
								submission.vote_by :voter => current_user
								response = showJson(submission)
								render json: {status: 'SUCCESS', message: 'Submission saved', data: response}, status: :ok
							else
								render json: {status: 'ERROR', message: 'Submission not saved', data: nil},
								:status => 500
							end
						else
							render json: {status: 'ERROR', message: 'Exists a submission with this url', data: nil},
								status: :unprocessable_entity
						end
					else
						render json: {status: 'ERROR', message: 'Error in parameters', data: nil},
							:status => 417
					end
				else
					render json: {status: 'ERROR', message: 'Error in authenticity', data: nil},
							:status => 403
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
					if Submission.where(id: params[:id]).present?
				    	submission = Submission.find(params[:id])
				    	if submission.user_id == current_user.id
					    	if submission.destroy
					    		render json: {status: 'SUCCESS', message: 'Submission deleted', data: nil},
									status: :ok
					    	else
					    		render json: {status: 'ERROR', message: 'Submission not deleted', data: nil},
									:status => 500
							end
						else
							render json: {status: 'ERROR', message: 'Cannot delete others submission', data: nil},
							:status => 403
						end
				    else
				    	render json: {status: 'ERROR', message: 'Submission does not exists', data: nil},
								status: :unprocessable_entity
				    end
			    else
			    	render json: {status: 'ERROR', message: 'Error in authenticity', data: nil},
							:status => 403
		    	end
		    end

			private

			def submission_params
				params.require(:submission).permit(:title, :url, :text, :user_id)
			end
		end
	end
end
