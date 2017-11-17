# Display a friendly welcoming message to non-contributors
contributors = github.api.contributors("JohnSundell/ImagineEngine").map { |user| user.login }

unless contributors.include? github.pr_author
    message "Hi @#{github.pr_author} 👋! Thank you for contributing to Imagine Engine! I'm the CI Bot for this project, and will assist you in getting your PR merged 👍"
end

# Show SwiftLint warnings inline in the diff
swiftlint.lint_files inline_mode: true

# Warning to discourage big PRs
if git.lines_of_code > 500
    warn "Your PR has over 500 lines of code 😱 Try to break it up into separate PRs if possible 👍"
end

# Warning to encourage a PR description
if github.pr_body.length == 0
    warn "Please add a decription to your PR to make it easier to review 👌"
end

# Encourage rebases instead of including merge commits
if git.commits.any? { |c| c.message =~ /^Merge branch 'master'/ }
  warn "Please rebase to get rid of the merge commits in this PR 🙏"
end

# If changes have been made in sources, encourage tests
if !git.modified_files.grep(/Sources/).empty? && git.modified_files.grep(/Tests/).empty?
    warn "Remember to write tests in case you have added a new API or fixed a bug. Feel free to ask for help if you need it 👍"
end
