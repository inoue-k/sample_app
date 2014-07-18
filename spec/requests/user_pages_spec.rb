# -*- coding: utf-8 -*-
require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "signup page" do
    # テストの直前にブレークポイントをいれる
    # before { binding.pry }

    before { visit signup_path }

    it { should have_content('Sign up') }
    it { should have_title(full_title('Sign up')) }
  end
end
