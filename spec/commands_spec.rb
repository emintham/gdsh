require_relative 'spec_helper'
require_relative '../lib/gdsh/commands'

describe Commands, '#interpret' do
  it 'creates an Unrecognized Command object' do
    expect(Commands.interpret('abc')).to eq(Commands::Unrecognized)
  end

  it 'creates a Quit Command object' do
    expect(Commands.interpret('quit')).to eq(Commands::Quit)
  end
    
  it 'creates a Help Command object' do
    expect(Commands.interpret('help')).to eq(Commands::Help)
  end

  it 'creates a Clear Command object' do
    expect(Commands.interpret('clear')).to eq(Commands::Clear)
  end

  it 'creates a ListFiles Command object' do
    expect(Commands.interpret('ls')).to eq(Commands::ListFiles)
  end

  it 'creates a UploadTemplate Command object' do
    expect(Commands.interpret('upload_template')).to eq(Commands::UploadTemplate)
  end

  it 'creates a QueryRevision Command object' do
    expect(Commands.interpret('query')).to eq(Commands::QueryRevision)
  end

  it 'creates a GetFile Command object' do
    expect(Commands.interpret('get')).to eq(Commands::GetFile)
  end

  it 'creates a RevisionDiff Command object' do
    expect(Commands.interpret('diff')).to eq(Commands::RevisionDiff)
  end
end
