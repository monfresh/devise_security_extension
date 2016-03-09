require 'test_helper'

class Devise::PasswordExpiredControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.create(username: 'hello', email: 'hello@path.travel',
                        password: '1234', password_changed_at: 3.months.ago)
  end

  test 'renders show when user needs password change' do
    sign_in(@user)
    get :show

    assert_template :show
  end

  test '#show redirects to root when user does not need password change' do
    user = User.create(username: 'hello', password: '1234')
    sign_in(user)
    get :show

    assert_redirected_to root_path
  end

  test '#show redirects to root when resource is not present' do
    get :show

    assert_redirected_to root_path
    assert_nil flash[:notice]
  end

  test '#update redirects to root when resource is not present' do
    patch :update

    assert_redirected_to root_path
    assert_nil flash[:notice]
  end

  test 'updates password and redirects to root when resource is present' do
    sign_in @user
    patch :update,
          user: {
            current_password: '1234',
            password: 'newpassword',
            password_confirmation: 'newpassword'
          }

    assert_redirected_to root_path
    assert_equal 'Your new password is saved.', flash[:notice]
    refute_equal @user.encrypted_password, @user.reload.encrypted_password
  end

  test 'renders show when password does not match password_confirmation' do
    sign_in @user
    patch :update,
          user: {
            current_password: '1234',
            password: 'newpassword',
            password_confirmation: ''
          }

    assert_template :show
  end

  test 'renders show when new password is same as current password' do
    sign_in @user
    patch :update,
          user: {
            current_password: '1234',
            password: '1234',
            password_confirmation: '1234'
          }

    assert_template :show
  end

  test 'renders show when current password is wrong' do
    sign_in @user
    patch :update,
          user: {
            current_password: 'invalidpassword',
            password: 'password1',
            password_confirmation: 'password1'
          }

    assert_template :show
  end

  test 'renders show when current password is blank' do
    sign_in @user
    patch :update,
          user: {
            current_password: '',
            password: 'password1',
            password_confirmation: 'password1'
          }

    assert_template :show
  end

  test 'renders show when only current password is filled in' do
    sign_in @user
    patch :update,
          user: {
            current_password: '1234',
            password: '',
            password_confirmation: ''
          }

    assert_template :show
  end
end
