@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class BackerDashboardProjectCellViewModelTests: TestCase {
  private let vm: BackerDashboardProjectCellViewModelType = BackerDashboardProjectCellViewModel()

  private let metadataIconIsHidden = TestObserver<Bool, Never>()
  private let metadataText = TestObserver<String, Never>()
  private let prelaunchProject = TestObserver<Bool, Never>()
  private let percentFundedText = TestObserver<String, Never>()
  private let photoURL = TestObserver<String, Never>()
  private let progress = TestObserver<Float, Never>()
  private let progressBarColor = TestObserver<UIColor, Never>()
  private let projectTitleText = TestObserver<String, Never>()
  private let savedIconIsHidden = TestObserver<Bool, Never>()

  override func setUp() {
    super.setUp()
    self.vm.outputs.metadataIconIsHidden.observe(self.metadataIconIsHidden.observer)
    self.vm.outputs.metadataText.observe(self.metadataText.observer)
    self.vm.outputs.percentFundedText.map { $0.string }.observe(self.percentFundedText.observer)
    self.vm.outputs.photoURL.map { $0?.absoluteString ?? "" }.observe(self.photoURL.observer)
    self.vm.outputs.progress.observe(self.progress.observer)
    self.vm.outputs.prelaunchProject.observe(self.prelaunchProject.observer)
    self.vm.outputs.progressBarColor.observe(self.progressBarColor.observer)
    self.vm.outputs.projectTitleText.map { $0.string }.observe(self.projectTitleText.observer)
    self.vm.outputs.savedIconIsHidden.observe(self.savedIconIsHidden.observer)
  }

  func testProjectData_Live() {
    let endingInDays = self.dateType.init().timeIntervalSince1970 + 60.0 * 60.0 * 24.0 * 14.0

    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.stats.fundingProgress .~ 0.5
      |> Project.lens.dates.deadline .~ endingInDays

    self.vm.inputs.configureWith(project: project)

    self.metadataIconIsHidden.assertValues([false])
    self.metadataText.assertValues(["14 days"])
    self.percentFundedText.assertValues(["50%"])
    self.photoURL.assertValues(["http://www.lazybathtubcat.com/vespa.jpg"])
    self.progress.assertValues([0.5])
    self.progressBarColor.assertValues([UIColor.ksr_create_700])
    self.projectTitleText.assertValues(["Best of Lazy Bathtub Cat"])
    self.savedIconIsHidden.assertValues([true])
  }

  func testProjectData_Successful() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.stats.fundingProgress .~ 1.1
      |> Project.lens.state .~ .successful

    self.vm.inputs.configureWith(project: project)

    self.metadataIconIsHidden.assertValues([true])
    self.metadataText.assertValues(["Successful"])
    self.percentFundedText.assertValues(["110%"])
    self.photoURL.assertValues(["http://www.lazybathtubcat.com/vespa.jpg"])
    self.progress.assertValues([1.1])
    self.progressBarColor.assertValues([UIColor.ksr_create_700])
    self.projectTitleText.assertValues(["Best of Lazy Bathtub Cat"])
    self.savedIconIsHidden.assertValues([true])
  }

  func testProjectData_Failed() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.stats.fundingProgress .~ 0.2
      |> Project.lens.state .~ .failed

    self.vm.inputs.configureWith(project: project)

    self.metadataIconIsHidden.assertValues([true])
    self.metadataText.assertValues(["Unsuccessful"])
    self.percentFundedText.assertValues(["20%"])
    self.photoURL.assertValues(["http://www.lazybathtubcat.com/vespa.jpg"])
    self.progress.assertValues([0.2])
    self.progressBarColor.assertValues([UIColor.ksr_support_300])
    self.projectTitleText.assertValues(["Best of Lazy Bathtub Cat"])
    self.savedIconIsHidden.assertValues([true])
  }

  func testProjectData_Saved() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.stats.fundingProgress .~ 1.1
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isStarred .~ true

    self.vm.inputs.configureWith(project: project)

    self.metadataIconIsHidden.assertValues([true])
    self.metadataText.assertValues(["Successful"])
    self.percentFundedText.assertValues(["110%"])
    self.photoURL.assertValues(["http://www.lazybathtubcat.com/vespa.jpg"])
    self.progress.assertValues([1.1])
    self.progressBarColor.assertValues([UIColor.ksr_create_700])
    self.projectTitleText.assertValues(["Best of Lazy Bathtub Cat"])
    self.savedIconIsHidden.assertValues([false])
  }

  func testProjectData_Prelaunch() {
    let project = .template
      |> Project.lens.name .~ "Best of Lazy Bathtub Cat"
      |> Project.lens.photo.full .~ "http://www.lazybathtubcat.com/vespa.jpg"
      |> Project.lens.displayPrelaunch .~ true
      |> Project.lens.personalization.isStarred .~ true

    self.prelaunchProject.assertDidNotEmitValue()

    self.vm.inputs.configureWith(project: project)

    self.prelaunchProject.assertValues([true])
  }
}
