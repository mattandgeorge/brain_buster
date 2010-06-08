require 'humane_integer'

 # Simple model to hold sets of questions and answers.
class BrainBuster < CouchRest::ExtendedDocument
	extend ActiveModel::Naming
  include ActiveModel::Conversion

	VERSION = "0.8.3"

	property :question
	property :answer

	view_by :question

	def self.create(question, answer)
		# Don't duplicate questions
		existing_questions = by_question(:key => question)
		if existing_questions.length == 0
			instance = new
			instance.question = question
			instance.answer = answer
    	instance.create
    	instance
		else
			nil
		end
	end

  # Attempt to answer a captcha, returns true if the answer is correct.
  def attempt?(string)
    string = string.strip.downcase
    if answer_is_integer?
      return string == answer || string == HumaneInteger.new(answer.to_i).to_english
    else
      return string == answer.downcase
    end
  end

  def self.find_random_or_previous(id = nil)
    id ? find_specific_or_fallback(id) : find_random
  end

  def self.random_function
		""
    #case connection.adapter_name.downcase
    #  when /sqlite/, /postgres/ then "random()"
    #  else                           "rand()"
    #end
  end
	
	# Borrowed from CouchRestRails
	def self.use_database(db)
		db = [COUCHDB_CONFIG[:db_prefix], db.to_s, COUCHDB_CONFIG[:db_suffix]].join
		self.database = COUCHDB_SERVER.database(db)
	end

  def self.find_specific_or_fallback(id)
    result = get(id)
		debugger
		if !result
    	find_random
		end
  end

  private
  
  def self.find_random
		i = rand(all.length)
		if all.length > 0
			all[i]
		end
  end
  
  
  def answer_is_integer?
    int_answer = answer.to_i
    (int_answer != 0) || (int_answer == 0 && answer == "0")
  end
  
end
