require 'base64'

class Gitlab::Client
  # Defines methods related to repository files.
  # @see https://docs.gitlab.com/ce/api/repository_files.html
  module RepositoryFiles
    # Get the contents of a file
    #
    # @example
    #   Gitlab.file_contents(42, 'Gemfile')
    #   Gitlab.repo_file_contents(3, 'Gemfile', 'ed899a2f4b50b4370feeea94676502b42383c746')
    #
    # @param  [Integer, String] project The ID or name of a project.
    # @param  [String] filepath The relative path of the file in the repository
    # @param  [String] ref The name of a repository branch or tag or if not given the default branch.
    # @return [String]
    def file_contents(project, filepath, ref='master')
      ref = URI.encode(ref, /\W/)
      get "/projects/#{url_encode project}/repository/files/#{url_encode filepath}/raw",
          query: { ref: ref},
          format: nil,
          headers: { Accept: 'text/plain' },
          parser: ::Gitlab::Request::Parser
    end
    alias_method :repo_file_contents, :file_contents

    # Gets a repository file.
    #
    # @example
    #   Gitlab.get_file(42, "README.md", "master")
    #
    # @param  [Integer, String] project The ID or name of a project.
    # @param  [String] file_path The full path of the file.
    # @param  [String] ref The name of branch, tag or commit.
    # @return [Gitlab::ObjectifiedHash]
    def get_file(project, file_path, ref)
      get("/projects/#{url_encode project}/repository/files/#{url_encode file_path}", query: {
            ref: ref
          })
    end

    # Creates a new repository file.
    #
    # @example
    #   Gitlab.create_file(42, "path", "branch", "content", "commit message")
    #
    # @param  [Integer, String] project The ID or name of a project.
    # @param  [String] full path to new file.
    # @param  [String] the name of the branch.
    # @param  [String] file content.
    # @param  [String] commit message.
    # @return [Gitlab::ObjectifiedHash]
    def create_file(project, path, branch, content, commit_message)
      post("/projects/#{url_encode project}/repository/files/#{url_encode path}", body: {
        branch_name: branch,
        commit_message: commit_message
      }.merge(encoded_content_attributes(content)))
    end

    # Edits an existing repository file.
    #
    # @example
    #   Gitlab.edit_file(42, "path", "branch", "content", "commit message")
    #
    # @param  [Integer, String] project The ID or name of a project.
    # @param  [String] full path to new file.
    # @param  [String] the name of the branch.
    # @param  [String] file content.
    # @param  [String] commit message.
    # @return [Gitlab::ObjectifiedHash]
    def edit_file(project, path, branch, content, commit_message)
      put("/projects/#{url_encode project}/repository/files/#{url_encode path}", body: {
        branch_name: branch,
        commit_message: commit_message
      }.merge(encoded_content_attributes(content)))
    end

    # Removes an existing repository file.
    #
    # @example
    #   Gitlab.remove_file(42, "path", "branch", "commit message")
    #
    # @param  [Integer, String] project The ID or name of a project.
    # @param  [String] full path to new file.
    # @param  [String] the name of the branch.
    # @param  [String] commit message.
    # @return [Gitlab::ObjectifiedHash]
    def remove_file(project, path, branch, commit_message)
      delete("/projects/#{url_encode project}/repository/files/#{url_encode path}", body: {
               branch_name: branch,
               commit_message: commit_message
             })
    end

    private

    def encoded_content_attributes(content)
      {
        encoding: 'base64',
        content: Base64.encode64(content)
      }
    end
  end
end
