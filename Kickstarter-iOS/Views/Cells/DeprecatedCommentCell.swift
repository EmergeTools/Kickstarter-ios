import KsApi
import Library
import Prelude
import UIKit

internal final class DeprecatedCommentCell: UITableViewCell, ValueCell {
  fileprivate let viewModel = DeprecatedCommentCellViewModel()

  @IBOutlet fileprivate var authorAndTimestampStackView: UIStackView!
  @IBOutlet fileprivate var authorStackView: UIStackView!
  @IBOutlet fileprivate var avatarImageView: UIImageView!
  @IBOutlet fileprivate var bodyTextView: UITextView!
  @IBOutlet fileprivate var commentStackView: UIStackView!
  @IBOutlet fileprivate var creatorLabel: UILabel!
  @IBOutlet fileprivate var creatorView: UIView!
  @IBOutlet fileprivate var nameLabel: UILabel!
  @IBOutlet fileprivate var rootStackView: UIStackView!
  @IBOutlet fileprivate var separatorView: UIView!
  @IBOutlet fileprivate var timestampLabel: UILabel!
  @IBOutlet fileprivate var youLabel: UILabel!
  @IBOutlet fileprivate var youView: UIView!

  internal override func bindStyles() {
    super.bindStyles()

    let cellBackgroundColor = UIColor.ksr_white

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.backgroundColor .~ cellBackgroundColor
      |> UITableViewCell.lens.contentView.layoutMargins .~
      .init(topBottom: Styles.grid(3), leftRight: Styles.grid(2))

    _ = self.avatarImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.bodyTextView
      |> UITextView.lens.isScrollEnabled .~ false
      |> UITextView.lens.textContainerInset .~ UIEdgeInsets.zero
      |> UITextView.lens.textContainer.lineFragmentPadding .~ 0
      |> UITextView.lens.backgroundColor .~ cellBackgroundColor

    _ = self.authorAndTimestampStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = self.authorStackView
      |> UIStackView.lens.spacing .~ Styles.gridHalf(1)

    _ = self.commentStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.backgroundColor .~ cellBackgroundColor

    _ = self.creatorLabel
      |> deprecatedAuthorBadgeLabelStyle
      |> UILabel.lens.textColor .~ .ksr_white
      |> UILabel.lens.text %~ { _ in Strings.update_comments_creator() }
      |> UILabel.lens.backgroundColor .~ .ksr_support_700

    _ = self.creatorView
      |> deprecatedAuthorBadgeViewStyle
      |> UIView.lens.backgroundColor .~ .ksr_support_700

    _ = self.nameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 16.0)
      |> UILabel.lens.textColor .~ .ksr_support_700
      |> UILabel.lens.backgroundColor .~ cellBackgroundColor

    _ = self.rootStackView
      |> UIStackView.lens.spacing .~ Styles.grid(2)

    _ = self.separatorView
      |> separatorStyle

    _ = self.timestampLabel
      |> UILabel.lens.font .~ .ksr_body(size: 12.0)
      |> UILabel.lens.textColor .~ .ksr_support_400
      |> UILabel.lens.backgroundColor .~ cellBackgroundColor

    _ = self.youLabel
      |> deprecatedAuthorBadgeLabelStyle
      |> UILabel.lens.textColor .~ .ksr_white
      |> UILabel.lens.text %~ { _ in Strings.update_comments_you() }

    _ = self.youView
      |> deprecatedAuthorBadgeViewStyle
      |> UIView.lens.backgroundColor .~ .ksr_create_700
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.avatarUrl
      .observeForUI()
      .on(event: { [weak self] _ in
        self?.avatarImageView.af.cancelImageRequest()
        self?.avatarImageView.image = nil
      })
      .skipNil()
      .observeValues { [weak self] url in
        self?.avatarImageView.af.setImage(withURL: url)
      }

    self.viewModel.outputs.bodyColor
      .observeForUI()
      .observeValues { [weak self] color in
        self?.bodyTextView.textColor = color
      }

    self.viewModel.outputs.bodyFont
      .observeForUI()
      .observeValues { [weak self] font in
        self?.bodyTextView.font = font
      }

    self.bodyTextView.rac.text = self.viewModel.outputs.body
    self.creatorView.rac.hidden = self.viewModel.outputs.creatorHidden
    self.nameLabel.rac.text = self.viewModel.outputs.name
    self.timestampLabel.rac.text = self.viewModel.outputs.timestamp
    self.youView.rac.hidden = self.viewModel.outputs.youHidden
  }

  internal func configureWith(value: (DeprecatedComment, Project, User?)) {
    self.viewModel.inputs.comment(value.0, project: value.1, viewer: value.2)
  }
}
