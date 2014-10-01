gem "minitest"
require 'minitest/autorun'
require 'database_cleaner'
require 'debugger'

class StudentModelTest < Minitest::Test
  def setup
    before_suite
    # set database transaction, so we can revert seeds
    DatabaseCleaner.start
    LT::Seeds::seed!
    @scenario = LT::Scenarios::Students::create_joe_smith_scenario
    @joe_smith = @scenario[:student]
    @jane_doe = @scenario[:teacher]
    @section = @scenario[:section]
    @page_visits = @scenario[:page_visits]
    @site_visits = @scenario[:site_visits]
    @sites = @scenario[:sites]
    @pages = @scenario[:pages]
  end

  def test_relationships
    # basic data relationships
    student = Student.find_by_username(@joe_smith[:username])
    teacher = StaffMember.find_by_username(@jane_doe[:username])
    assert_equal @joe_smith[:username], student.username
    assert student.user
    assert_equal @joe_smith[:email], student.email
    assert_equal @jane_doe[:username], teacher.username
    # teachers belong to sections
    section = teacher.sections.find_by_section_code(@section[:section_code])
    assert_equal @section[:section_code], section.section_code
    assert_equal 'Teacher', section.teachers.first.user_type
    # students belong to sections
    section = student.sections.find_by_section_code(@section[:section_code])
    assert_equal @section[:section_code], section.section_code
    su = section.students
    joe_smith_section_student = su.detect do |student|
      student.username == @joe_smith[:username]
    end
    assert_equal @joe_smith[:username], joe_smith_section_student.username
  end

  def test_page_site_visits
    # Joe Smith has visited some Khan Academy sites recently
    student = Student.find_by_username(@joe_smith[:username])
    teacher = StaffMember.find_by_username(@jane_doe[:username])
    assert_equal @site_visits.size, student.site_visits.size
    assert student.site_visits.size >= 2
    assert_equal @page_visits.size, student.page_visits.size
    assert student.page_visits.size >= 2
    section_found = 0
    joe_smith_found = 0
    khan_site_visit_count = 0
    first_page_visit_count = 0
    second_page_visit_count = 0
    students_in_section_count = 0
    each_page_visited_list = []
    # test data browsing that we expect to need for dashboard view
    teacher.sections.each do |section|
      if section.section_code == @section[:section_code] then
        section_found += 1
      end
      section.students.each do |student|
        students_in_section_count += 1
        if student.username == @joe_smith[:username] then
          joe_smith_found += 1
          student.each_site_visit do |site_visit|
            if site_visit.url == @sites.first[:url] then
              khan_site_visit_count += 1
            end
            student.each_page_visit(site: site_visit.site) do |page_visit|
              if site_visit.url == @sites.first[:url] then
                each_page_visited_list << page_visit
              end 
            end # student.each_page_visit
          end # if site_visit.url ==
        end # if student.username 
      end #section.students.each
    end # teacher.sections.each
    khan_site_visits_actual = @site_visits.count do |visit|
      visit[:url].match(/khanacademy/)
    end
    khan_page_visits_actual = @page_visits.count do |visit|
      visit[:url].match(/khanacademy/) && (visit[:date_visited] > Time.now - User::DEFAULT_VISIT_TIME_FRAME)
    end
    assert_equal khan_site_visits_actual, 2
    assert_equal khan_page_visits_actual, 3
    assert_equal 1, section_found
    assert_equal 1, joe_smith_found
    assert_equal 2, students_in_section_count
    assert_equal 1, khan_site_visit_count
    assert_equal 2, each_page_visited_list.uniq.size
    # loop through every page visited and make sure it's
    # in the list of @page_visits we expected
    each_page_visited_list.delete_if do |page_visit|
      @page_visits.find {|pv| 
        pv[:url] == page_visit.url
      }
    end
  
    assert_equal 0, each_page_visited_list.size
  end

  @first_run
  def before_suite
    if !@first_run
      DatabaseCleaner[:active_record].strategy = :transaction
      DatabaseCleaner[:redis].strategy = :truncation
    end
    @first_run = true
  end

  def teardown
    DatabaseCleaner.clean # cleanup of the database
  end
end

