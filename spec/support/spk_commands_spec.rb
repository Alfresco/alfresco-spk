require File.dirname(__FILE__) + './../spec_helper'

describe SpkCommands do
	before do
		@params = VagrantPlugins::Spk::Config.new
		@engine = VagrantPlugins::Spk::Commons::Engine.new
		@env_vars = "command"
		@file_list = []
		@mode = ""
	end

	describe "Class instantiations" do
	  it 'should not accept an empty initialization' do
			expect { SpkCommands.new() }.to raise_error(ArgumentError)
		end

		it 'should not accept only an params as unique parameter' do
			expect { SpkCommands.new(@params)}.to raise_error(ArgumentError)
		end

		it 'should not accept only engine and parameters as unique parameter' do
			expect { SpkCommands.new(@params, @engine)}.to raise_error(ArgumentError)
		end

		it 'should not accept only engine, parameters and file_list as unique parameters' do
			expect{ SpkCommands.new(@params, @engine, @file_list ) }.to raise_error(ArgumentError)
		end

		it 'should not accept only engine, parameters, file list and env_vars as parameters' do
			expect{ SpkCommands.new(@params, @engine, @file_list, @env_vars ) }.to raise_error(ArgumentError)
		end

		it 'should instanciate correctly only if all four parameters exists' do
			expect{ SpkCommands.new(@params, @engine, @file_list, @env_vars, @mode) }.to_not raise_error
		end
	end


	describe 'Parameter validation' do
		it 'should not accept anything else other than a Vangrant Config class to run' do
			@commands = SpkCommands.new({}, @engine, ["commands.json"], @env_vars, "pre")
			expect { @commands.send(:validate)}.to raise_error(ArgumentError, "Params should be an instance of VagrantPlugins::Spk::Config")
		end

		it 'should not accept anything else other than an SPK engine class to run ' do
			@commands = SpkCommands.new(@params, {}, ["commands.json"], @env_vars, "pre")
			expect { @commands.send(:validate)}.to raise_error(ArgumentError, "Engine should be an instance of VagrantPlugins::Spk::Commons::Engine")
		end

	  it 'should not accept an empty file list as commands' do
	  	@commands = SpkCommands.new(@params, @engine, [], @env_vars, "pre")
	  	expect { @commands.send(:validate) }.to raise_error(ArgumentError, "File list needs to be an Array, and cannot be empty")
	  end

	  it 'should not accept an empty string as command mode' do
	  	@commands = SpkCommands.new(@params, @engine, ["commands.json"], @env_vars, "")
	  	expect { @commands.send(:validate) }.to raise_error(ArgumentError, "Mode should be either pre or post")
	  end

	  it 'should not accept a nil string as command mode' do
	  	@commands = SpkCommands.new(@params, @engine, ["commands.json"], @env_vars, nil)
	  	expect { @commands.send(:validate) }.to raise_error(ArgumentError, "Mode should be either pre or post")
	  end

	  it "should not accept anything other than 'post' or 'pre' as command mode" do
	  	@commands = SpkCommands.new(@params, @engine, ["commands.json"], @env_vars, "test")
	  	expect { @commands.send(:validate) }.to raise_error(ArgumentError, "Mode should be either pre or post")
	  end

	  it 'should not accept accept a nil variables list' do
	  	@commands = SpkCommands.new(@params, @engine, ["commands.json"], nil, "pre")
	  	expect { @commands.send(:validate) }.to raise_error(ArgumentError, "Environment variables should be a string and cannot be empty")
	  end

	  it 'should not accept accept an empty variables list' do
	  	@commands = SpkCommands.new(@params, @engine, ["commands.json"], "", "pre")
	  	expect { @commands.send(:validate) }.to raise_error(ArgumentError, "Environment variables should be a string and cannot be empty")
	  end

	  it "should validate correctly if all parameters are proper" do
	  	@commands = SpkCommands.new(@params, @engine, ["commands.json"], @env_vars, "post")
	  	expect { @commands.send(:validate) }.to_not raise_error
	  end

	end
	

end