require 'spec_helper'

class MyMailTest < ActionMailer::Base
  
  def test(resource = User.first, options = {})
    lazy_mail resource, options
  end
  
  def test_res(*args)
    lazy_mail *args
  end
  
  def test_client(*args)
    lazy_mail *args
  end
  
  def test_fail
    lazy_mail
  end
  
  def test_obj(*args)
    lazy_mail *args
  end
  
end

describe LazyMail, :type => :mailer do
  
  before :each do
    LazyMail.user_model = User
    LazyMail.default_no_reply = 'no-reply@test.com'
    LazyMail.mailer_templates_path = '../../spec/notifications'
    I18n.locale = :en
    @user = User.first
  end
  
  describe "mail by default"  do
    
    before :each do
      @mail = MyMailTest.test
    end
    
    it "should return user email" do
      @mail.to.should == [ @user.email ]
    end
    
    it "should set the default from" do
      @mail.from.should == [ 'no-reply@test.com' ]
    end
    
    it "should find template based on locale" do
      @mail.body.should include('Hello')
    end
    
    it "should change template if locale changed" do
      I18n.locale = :fr
      @mail = MyMailTest.test
      @mail.subject.should == 'mon test email'
      @mail.body.should include('Bonjour')
    end
    
    it "should send to mail_view the user object" do
      @mail.body.should include(@user.username)
    end
    
  end
  
  describe "with options (like mail)" do
    
    it "should change from" do
      options = { :from => 'one@test.mail' }
      mail = MyMailTest.test(@user, options)
      mail.from.should == [ 'one@test.mail' ]
    end
    
    it "should works with many options" do
      options = { :to => 'test@mail.com', :subject => 'my subject' }
      mail = MyMailTest.test(@user, options)
      mail.to.should == [ 'test@mail.com' ]
      mail.subject.should == 'my subject'
    end
    
    it "should change the template" do
      options = { :template_path => '../../spec/notifications/my_mail_test/fr' }
      mail = MyMailTest.test(@user, options)
      I18n.locale.should == :en
      mail.body.should include('Bonjour')
    end
    
    it "option :to could have a list of emails" do
      my_array = ['test@mail.com', 'test_1@mail.com', 'test_2@mail.com']
      options = { :to => my_array }
      mail = MyMailTest.test(@user, options)
      mail.to.should == my_array
    end
    
    it "option :from could have a list of emails" do
      my_array = ['test@mail.com', 'test_1@mail.com', 'test_2@mail.com']
      options = { :from => my_array }
      mail = MyMailTest.test(@user, options)
      mail.from.should == my_array
    end
    
    it "should change the no-reply with initiatializer" do
      LazyMail.default_no_reply = 'tom@no-reply-test.com'
      mail = MyMailTest.test
      mail.from.should == [ 'tom@no-reply-test.com' ]
    end
    
  end
  
  describe "i18n scope" do
    
    it "should work" do
      mail = MyMailTest.test
      mail.subject.should == 'my test mail'
    end
    
    it "should work with i18n default rails scope" do
      LazyMail.i18n_scope = nil
      mail = MyMailTest.test
      mail.subject.should == 'rails default'
    end
    
    it "should work with key words" do
      LazyMail.i18n_scope = [:action_name, :hey, :class_name, :test]
      mail = MyMailTest.test
      mail.subject.should == 'hey!'
    end
    
  end
  
  describe "should create resouces" do
    
    before :each do
      LazyMail.user_model = User
      LazyMail.email_field = :email
    end
    
    it "should works with many resources" do
      mail = MyMailTest.test_res(@user, Client.first, Other.first)
      mail.body.should == "tom, bob, plop"
    end
    
    it "should work with another model" do
      client = Client.first
      LazyMail.user_model = Client
      mail = MyMailTest.test_client(@user, client)
      mail.to.should == [ client.email ]
      mail.body.should == "bob: tom"
    end
    
    it "should work with another name than email" do
      other = Other.first
      LazyMail.user_model = Other
      LazyMail.email_field = :test_mail
      mail = MyMailTest.test_res(@user, Client.first, other)
      mail.to.should == [ other.test_mail ]
      mail.body.should == "tom, bob, plop"
    end
    
    it "should raise an error without user or options[:to]" do
      expect {
        MyMailTest.test(Client.first)
      }.to raise_error(ArgumentError)
    end
    
    it "should raise an error with no values" do
      expect {
        MyMailTest.test_fail
      }.to raise_error(ArgumentError)
    end 
       
    it "if user_model is not defined should raise an error" do
      LazyMail.user_model = nil
      expect {
        MyMailTest.test(@user)
      }.to raise_error(ArgumentError, 'lazy_mail: you need to define a user_model or use option :to')
    end
    
    it "should work with no ActiveRecord object" do
      mail = MyMailTest.test_obj(@user, ['Hi'], ['haha', 'plop'], "my_string", User.find_by_username('tomtom'))
      mail.body.should == "tom: Hi -> my_string - plop = tomtom"
    end
    
  end
  
  describe "mail in development" do
    
    before :each do
      Rails.stub!(:env).and_return('development')
    end
    
    describe "with string" do
      
      it "should overwrite user mail" do
        LazyMail.development_mail = 'tom@string.com'
        mail = MyMailTest.test
        mail.to.should == [ 'tom@string.com' ]
      end
      
    end
    
    describe "#git" do
      
      before :each do
        LazyMail.development_mail = :git
        class TestGit
          include LazyMail
        end
        @test_git = TestGit.new
      end
      
      it "should return current git user" do
        @test_git.stub!(:user_email).and_return("test@git.com\n")
        @test_git.send(:get_email).should == "test@git.com"
      end
      
      it "should return an error message" do
        @test_git.stub!(:user_email).and_return("\n")
        @test_git.should_receive(:warn)
        @test_git.send(:get_email)
      end
      
    end
  
  end

end