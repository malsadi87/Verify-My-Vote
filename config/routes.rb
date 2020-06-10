Rails.application.routes.draw do
  get 'main/index'
  get 'admin/index'
  get 'voter/index'
  get 'voter/elections'
  get 'voter/login'
  get 'voter/ballot'
  get 'voter/vote_summary'
  get 'voter/Profile'
  get 'voter/results'
  get 'voter/verify'


  get 'admin/index'
  get 'admin/dashboard'
  get 'admin/viewElections'
  get 'admin/startElection'
  get 'admin/sendVerificationParams'
  get 'admin/uploadPreElectionToBlockchain'



  ##############################################
   post "voter/login" => "voter#login"
   post "voter/ballot" => "voter#vote_summary"
   post "voter/Profile" => "voter#Profiles"
   post "voter/ballot" => "voter#vote_summary"
   post "voter/vote_summary" => "voter#castVote"
   post "voter/results" => "voter#results"
   post "voter/verify" => "voter#verify"


  post 'login' => 'admin#index', as: :login
  post "admin/index" => "admin#index"
  post "admin/sendVerificationParams" => "admin#sendVerificationParams"
  post "admin/uploadPreElectionToBlockchain" => "admin#uploadPreElectionToBlockchain"
  post "admin/startElection" => "admin#startElection"





  ##############################################

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'voter#elections'

end
