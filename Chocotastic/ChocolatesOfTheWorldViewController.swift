/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  let europeanChocolates = Observable.just(Chocolate.ofEurope)
  let disposeBag = DisposeBag()
  
  //MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    
    //TODO: Figure out how to disable editing 
    
    setupCellConfiguration()
    setupCellTapHandling()
    setupCartObserver()
  }
  
  //MARK: Rx Setup
  
  private func setupCellConfiguration() {
    //Equivalent of cell for row at index path
    europeanChocolates
      .bindTo(tableView
        .rx
        .items(cellIdentifier: ChocolateCell.Identifier, cellType: ChocolateCell.self)) {
          row, chocolate, cell in
          cell.configureWithChocolate(chocolate: chocolate)
      }
      .addDisposableTo(disposeBag)
  }
  
  private func setupCellTapHandling() {
    //Equivalent of did select row at index path
    tableView
      .rx
      .modelSelected(Chocolate.self)
      .subscribe(onNext: {
        chocolate in
        ShoppingCart.sharedCart.chocolates.value.append(chocolate)
        
        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
          self.tableView.deselectRow(at: selectedRowIndexPath, animated: true)
        }
      })
      .addDisposableTo(disposeBag)
  }
  
  private func setupCartObserver() {
    ShoppingCart.sharedCart.chocolates.asObservable()
      .subscribe(onNext: {
        chocolates in
        self.cartButton.title = "\(chocolates.count) \u{1f36b}"
      })
      .addDisposableTo(disposeBag)
  }
  
}

//MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  
  enum SegueIdentifier: String {
    case
    GoToCart
  }
}
