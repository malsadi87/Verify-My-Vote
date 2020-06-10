class AdminController < ApplicationController
  include ApplicationHelper
  include BlockchainHelper


  def index
    @user = params[:user]
    if !@user.nil?
      @email = @user[:email]
      @pass = @user[:password]
      if @email == "admin@admin.com" && @pass == "1111"
        puts "Login success"
        redirect_to :controller => 'admin', :action => 'dashboard', :name => @email
      else
        puts "try again later"
        redirect_to '/admin/index'
      end
    end
  end

  def viewElections
    require 'json'
    json = File.read('public/files/elections.json')
    puts json
    @ElectionArray = JSON.parse(json)
  end
  
  def dashboard
    @rn = (SecureRandom.random_number(9e7) + 1e7).to_i
    puts @rn
  end
  
  def startElection

    require 'json'
    require 'csv'

    @VotersList = CSV.parse(File.read('public/files/voters.csv'), headers: true)
    table = CSV.parse(File.read('public/files/ers-associated-voters.csv'), headers: true)

    name = params[:election]

    @VotersList.each do |voter|
      puts "voter id = #{voter["id"]} and code = #{voter["code"]}"
      voter_obj = table.select { |row| row['id'].to_i == voter["id"].to_i}

      helpers.beta(voter_obj.first["beta"])
      helpers.loglink("http://localhost:3000/voter/login?election=#{name}")
      helpers.code(voter["code"])

      ## Send an email with token to voters' email
      if voter["id"] == "4"
       VmvMailer.sample_email(voter["email"]).deliver
      end
    end

    ## Generate OTPs and send them to voters phones
    #helpers.send_otp

    flash[:success] = 'Emails with login credential are sent to voters.'
    redirect_to '/admin/viewElections'
  end
  
  def uploadPreElectionToBlockchain
    
    @uploaded = false
    contract = helpers.get_pre_election_contract
    if contract.nil?
      helpers.create_pre_election_contract
      contract = helpers.get_pre_election_contract
    end
    if ! contract.nil?
    publicVoters = CSV.parse(File.read('public/files/public-voters.csv'), headers: true)
    publicVoters.each do |voter|
      contract.transact_and_wait.add_voter_entry(voter["beta"].to_s, voter["encryptedTrackerNumberInGroup"].to_s, voter["publicKeySignature"].to_s, voter["publicKeyTrapdoor"].to_s)
    end
    @uploaded = true
    puts "uploaded value is #{@uploaded}"
    flash[:success] = 'PreElection voters details is published to Blockchain..'
    redirect_to '/admin/viewElections'
    end
  end
  
  def sendVerificationParams

    require 'json'
    require 'csv'
    @VotersList = CSV.parse(File.read('public/files/voters.csv'), headers: true)
    table = CSV.parse(File.read('public/files/ers-associated-voters.csv'), headers: true)

    @VotersList.each do |voter|
      #if voter["id"] == 3
      puts %(voter id : '#{voter["id"]}')
      voter_obj = table.select { |row| row['id'].to_i == voter["id"].to_i}
      #puts voter_obj.first["id"]
      vBeta = voter_obj.first["beta"]
      helpers.beta(vBeta)
      vAlpha = getAlphaValue(voter["id"])

      helpers.name(voter["name"])
      helpers.loglink("http://localhost:3000/voter/verify?election=DemoElection&beta=#{vBeta}&alpha=#{vAlpha}")
      ## Send an email with token to voters' email
      if voter["id"].to_i == 4
        puts "id macths and an email will be sent"
        VmvMailer.verification_email(voter["email"]).deliver
      end
    end

    ## Blockchain Part - Encrypted Votes
    contract = helpers.get_election_contract
    if contract.nil?
      helpers.create_election_contract
      contract = helpers.get_election_contract
    end
    encrypedVotes= CSV.parse(File.read('public/files/public-encrypted-voters.csv'), headers: true)
    contract.gas_price = 0
    contract.gas_limit = 8_000_000
    encrypedVotes.each do |vote|
      contract.transact_and_wait.add_record(vote["beta"].to_s, vote["encryptedVote"].to_s, vote["encryptedVoteSignature"].to_s, vote["encryptedTrackerNumberInGroup"].to_s, vote["publicKeySignature"].to_s, vote["publicKeyTrapdoor"].to_s)
    end


    ## Blockchain part - Plain Votes
    post_contract = helpers.get_post_election_contract
    if post_contract.nil?
      helpers.create_post_election_contract
      post_contract = helpers.get_post_election_contract
    end
    finalVotes= CSV.parse(File.read('public/files/public-mixed-voters.csv'), headers: true)

    finalVotes.each do |vote|
      post_contract.transact_and_wait.add_record(vote["trackerNumber"].to_s, vote["plainTextVote"].to_s)
    end

    flash[:success] = 'Verification parameters are sent successfully. Election Data is stored on Blockchain'
    redirect_to '/admin/viewElections'
  end

  def getAlphaValue(val)
    encryptedVoters = CSV.parse(File.read('public/files/ers-encrypted-voters.csv'), headers: true)
    record = encryptedVoters.select { |row| row['id'].to_i == val.to_i}.first
    return record['alpha']
  end

end
