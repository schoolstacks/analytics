class InitSchema < ActiveRecord::Migration
  def change
    create_table "approved_sites", :force => true do |t|
      t.string   "hash_id",      :null => false
      t.string   "url_pattern",  :null => false
      t.string   "css_selector", :null => false
      t.timestamps
    end
    
    create_table "janitor_jobs", :force => true do |t|
      t.string   "job_status"   # what are the status of the rows "IN PROGRESS" "FINISHED"
      t.string   "janitor_type" # what extractor is it?
      t.string   "job_id"       # what specific extractor 
      t.string   "table_name"
      t.integer  "table_id"
      t.timestamps
    end

    #"user id X viewed this page http://xyz (display "Understanding Fractions") at this time"
    # [user x] [viewed] [site y] [page z] on [date abc]"
    # user x = subject, verb = viewed, object = site y, object_detail = page z
    # date abc = occured_at
    # also store in result: "page display title" and "site display name"
    create_table "actions", :force => true do |t|
      t.string "subject"
      t.string "verb" 
      t.string "object" 
      t.string "object_detail"
      t.json "result"
        #"display title"
        #"display site"
      t.datetime "occurred_at"
      t.timestamps
    end

    create_table "raw_messages", :force => true do |t|
      t.integer  "status_id" # note this should probably be :null=>false once we have more code working
      t.string   "api_key",       :null => false
      t.string   "email",         :null => false
      t.string   "action"
      t.string   "event"
      t.string   "url"
      t.text     "html"
      t.datetime "captured_at"
      t.timestamps
    end
    
    create_table "schools", :force => true do |t|
      t.string   "state_id"
      t.string   "nces_id"
      t.string   "sis_id"
      t.string   "other_id"
      t.string   "name",         :null => false
      t.string   "address"
      t.string   "city"
      t.string   "state"
      t.string   "phone"
      t.string   "grade_low"
      t.string   "grade_high"
      t.timestamps
    end
    
    create_table "course_offerings", :force => true do |t|
      t.integer  "course_id",    :null => false
      t.string   "sis_id"
      t.string   "other_id"
      t.date     "date_start"
      t.date     "date_end"
      t.timestamps
    end
    
    create_table "courses", :force => true do |t|
      t.string   "course_code"
      t.string   "sis_id"
      t.string   "other_id"
      t.string   "name",                    :null => false
      t.string   "description"
      t.string   "subject_area"
      t.boolean  "high_school_requirement"
      t.timestamps
    end
    
    create_table "districts", :force => true do |t|
      t.string   "state_id"
      t.string   "nces_id"
      t.string   "sis_id"
      t.string   "other_id"
      t.string   "name",         :null => false
      t.string   "address"
      t.string   "city"
      t.string   "state"
      t.string   "phone"
      t.string   "grade_low"
      t.string   "grade_high"
      t.timestamps
    end

    create_table "sections", :force => true do |t|
      t.string   "section_code"
      t.integer  "course_offering_id", :null => false
      t.string   "sis_id"
      t.string   "other_id"
      t.string   "name",               :null => false
      t.timestamps
    end

    create_table "sections_users", :force => true do |t|
      t.string "relationship" # defines the type of relationship user has to section
        # e.g.: "teacher" "student" "TA" "auditing"
      t.belongs_to :section
      t.belongs_to :user
    end

    create_table "users", :force => true do |t|
      t.string   "first_name",    :null => false
      t.string   "middle_name"
      t.string   "last_name",     :null => false
      t.string   "gender"
      t.string   "username",     :null => false
      t.string   "password_hash"
      t.string   "password_salt"
      t.date     "date_of_birth"
      t.timestamps
    end

    add_index :users, :username, :unique => true

    create_table "emails", :force => true do |t|
      t.string   "email"
      t.boolean  "primary"
      t.belongs_to :user
    end

    create_table "api_keys", :force => true do |t|
      t.integer "user_id",      :null => false
      t.string  "key",          :null => false
      t.timestamps
    end

    create_table "students", :force => true do |t|
      t.string   "state_id"
      t.string   "sis_id"
      t.string   "other_id"
      t.string   "grade_level"
      t.belongs_to :user
      t.timestamps
    end

    create_table "staff_members", :force => true do |t|
      t.string   "state_id"
      t.string   "sis_id"
      t.string   "other_id"
      t.string   "staff_member_type", :null => false
      t.belongs_to :user
      t.timestamps
    end 
  end #def change
end # class migration
