import UIKit

class ProductDetailViewController: UIViewController {
    
    enum LayoutAttribute {
        static let largeSpacing: CGFloat = 30
        static let smallSpacing: CGFloat = 10
        
        enum TitleLabel {
            static let fontSize: CGFloat = 17
        }
        
        enum StockLabel {
            static let textStyle: UIFont.TextStyle = .body
            static let stockFontColor: UIColor = .systemGray
            static let soldoutFontColor: UIColor = .orange
        }
        
        enum PriceLabel {
            static let textStyle: UIFont.TextStyle = .body
            static let originalPriceFontColor: UIColor = .red
            static let bargainPriceFontColor: UIColor = .systemGray
        }
        
        enum DescriptionTextView {
            static let textStyle: UIFont.TextStyle = .body
        }
    }
    
    typealias Product = NetworkingAPI.ProductDetailQuery.Response
    
    private var backButtonItem: UIBarButtonItem!
    private var modificationButtonItem: UIBarButtonItem!
    private let acitivityIndicator = UIActivityIndicatorView()
    private let imageScrollView = UIScrollView()
    private let imageStackView = UIStackView()
    private let productTitleLabel = UILabel()
    private let productStockLabel = UILabel()
    private let productPriceLabel = UILabel()
    private let productDescriptionTextView = UITextView()

    var productId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        create()
        organizeViewHierarchy()
        configure()
        fetchProductDetail()
    }
    
    private func create() {
        createBackButtonItem()
        createModificationButtonItem()
    }
    
    private func organizeViewHierarchy() {
        navigationItem.setLeftBarButton(backButtonItem, animated: false)
        navigationItem.setRightBarButton(modificationButtonItem, animated: false)
        
        view.addSubview(acitivityIndicator)
        view.addSubview(imageScrollView)
        view.addSubview(productTitleLabel)
        view.addSubview(productStockLabel)
        view.addSubview(productPriceLabel)
        view.addSubview(productDescriptionTextView)
        
        imageScrollView.addSubview(imageStackView)
    }
    
    private func configure() {
        configureMainView()
        configureAcitivityIndicator()
        configureImageScrollView()
        configureImageStackView()
        configureProductTitleLabel()
        configureProductStockLabel()
        configureProductPriceLabel()
        configureProductDescriptionTextView()
    }

    private func configureMainView() {
        view.backgroundColor = .systemBackground
    }
}

//MARK: - BackButtonItem
extension ProductDetailViewController {
    
    private func createBackButtonItem() {
        backButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(dismissProductDetailViewController))
    }
    
    @objc private func dismissProductDetailViewController() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - NavigationTitle
extension ProductDetailViewController {
    
    private func updateNavigationTitle(from product: Product) {
        navigationItem.title = product.name
    }
}

//MARK: - ModificationButtonItem
extension ProductDetailViewController {
    
    private func createModificationButtonItem() {
        modificationButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(modifyOrDeleteProduct))
    }
    
    @objc private func modifyOrDeleteProduct() {
        
    }
}

//MARK: - AcitivityIndicator
extension ProductDetailViewController {
    
    private func configureAcitivityIndicator() {
        acitivityIndicator.startAnimating()
        acitivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            acitivityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            acitivityIndicator.widthAnchor.constraint(equalTo: view.widthAnchor),
            acitivityIndicator.heightAnchor.constraint(equalTo: acitivityIndicator.widthAnchor,
                                                      constant: -2 * LayoutAttribute.largeSpacing),
            acitivityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
    }
}

//MARK: - ImageScrollView
extension ProductDetailViewController {
    
    private func configureImageScrollView() {
        imageScrollView.isPagingEnabled = true
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageScrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageScrollView.heightAnchor.constraint(equalTo: imageScrollView.widthAnchor,
                                                    constant: -2 * LayoutAttribute.largeSpacing),
            imageScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
    }
}

//MARK: - ImageStackView
extension ProductDetailViewController {
    
    private func configureImageStackView() {
        imageStackView.axis = .horizontal
        imageStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageStackView.heightAnchor.constraint(equalTo: view.widthAnchor),
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.topAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.trailingAnchor),
        ])
    }
    
    private func updateImageStackView(from product: Product) {
        product.images.forEach {
            ImageLoader.load(from: $0.url) { (result) in
                switch result {
                case .success(let data):
                    DispatchQueue.main.sync {
                        guard let image = UIImage(data: data) else {
                            print(OpenMarketError.conversionFail("data", "UIImage"))
                            return
                        }
                        self.addToStack(image: image)
                        self.acitivityIndicator.stopAnimating()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func addToStack(image: UIImage) {
        let imageView = UIImageView()
        imageView.image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0,
                                                                     left: -1 * LayoutAttribute.largeSpacing,
                                                                     bottom: 0,
                                                                     right: -1 * LayoutAttribute.largeSpacing))
        imageStackView.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageStackView.heightAnchor),
            imageView.heightAnchor.constraint(equalTo: imageStackView.heightAnchor)
        ])
    }
}

//MARK: - ProductTitleLabel
extension ProductDetailViewController {
    
    private func configureProductTitleLabel() {
        productTitleLabel.font = UIFont.dynamicBoldSystemFont(ofSize: LayoutAttribute.TitleLabel.fontSize)
        productTitleLabel.adjustsFontForContentSizeCategory = true
        productTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productTitleLabel.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor,
                                                   constant: LayoutAttribute.smallSpacing),
            productTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                       constant: LayoutAttribute.largeSpacing)
        ])
    }
    
    private func updateProductTitleLabel(from product: Product) {
        productTitleLabel.text = product.name
    }
}

//MARK: - ProductStockLabel
extension ProductDetailViewController {
    
    private func configureProductStockLabel() {
        productStockLabel.font = .preferredFont(forTextStyle: LayoutAttribute.StockLabel.textStyle)
        productStockLabel.adjustsFontForContentSizeCategory = true
        productStockLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productStockLabel.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor,
                                                   constant: LayoutAttribute.smallSpacing),
            productStockLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                        constant: -1 * LayoutAttribute.largeSpacing)
        ])
    }
    
    private func updateProductStockLabel(from product: Product) {
        if product.stock == 0 {
            productStockLabel.text = "품절"
            productStockLabel.textColor = LayoutAttribute.StockLabel.soldoutFontColor
        } else {
            productStockLabel.text = "잔여수량: \(product.stock)"
            productStockLabel.textColor = LayoutAttribute.StockLabel.stockFontColor
        }
    }
}

//MARK: - ProductPriceLabel
extension ProductDetailViewController {
    
    private func configureProductPriceLabel() {
        productPriceLabel.numberOfLines = 0
        productPriceLabel.adjustsFontForContentSizeCategory = true
        productPriceLabel.textAlignment = .right
        productPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productPriceLabel.topAnchor.constraint(equalTo: productStockLabel.bottomAnchor,
                                                   constant: LayoutAttribute.smallSpacing),
            productPriceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                        constant: -1 * LayoutAttribute.largeSpacing)
        ])
    }
    
    private func updateProductPriceLabel(from product: Product) {
        let blank = NSMutableAttributedString(string: " ")
        let lineBreak = NSMutableAttributedString(string: "\n")
        let currency = NSMutableAttributedString(string: product.currency.rawValue)
        guard let originalPrice = NSMutableAttributedString(string: product.price.description).toDecimal,
              let bargainPrice = NSMutableAttributedString(string: product.bargainPrice.description).toDecimal else {
                  print(OpenMarketError.conversionFail("basic NSMutableAttributedString", "decimal").description)
                  return
              }
        
        let result = NSMutableAttributedString(string: "")
        if product.price != product.bargainPrice {
            let originalPriceDescription = NSMutableAttributedString()
            originalPriceDescription.append(currency)
            originalPriceDescription.append(blank)
            originalPriceDescription.append(originalPrice)
            originalPriceDescription.setStrikeThrough()
            originalPriceDescription.setFontColor(to: LayoutAttribute.PriceLabel.originalPriceFontColor)
            
            let bargainPriceDescription = NSMutableAttributedString()
            bargainPriceDescription.append(currency)
            bargainPriceDescription.append(blank)
            bargainPriceDescription.append(bargainPrice)
            bargainPriceDescription.setFontColor(to: LayoutAttribute.PriceLabel.bargainPriceFontColor)
            
            result.append(originalPriceDescription)
            result.append(lineBreak)
            result.append(bargainPriceDescription)
        } else {
            let bargainPriceDescription = NSMutableAttributedString()
            bargainPriceDescription.append(currency)
            bargainPriceDescription.append(blank)
            bargainPriceDescription.append(bargainPrice)
            bargainPriceDescription.setFontColor(to: LayoutAttribute.PriceLabel.bargainPriceFontColor)

            result.append(bargainPriceDescription)
        }
        
        result.setTextStyle(textStyle: LayoutAttribute.PriceLabel.textStyle)
        productPriceLabel.attributedText = result
    }
}

//MARK: - ProductDescriptionTextView
extension ProductDetailViewController {
    
    private func configureProductDescriptionTextView() {
        productDescriptionTextView.font = .preferredFont(forTextStyle: LayoutAttribute.DescriptionTextView.textStyle)
        productDescriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            productDescriptionTextView.topAnchor.constraint(equalTo: productPriceLabel.bottomAnchor,
                                                            constant: LayoutAttribute.smallSpacing),
            productDescriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                                constant: LayoutAttribute.largeSpacing),
            productDescriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                                constant: -1 * LayoutAttribute.largeSpacing),
            productDescriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func updateProductDescriptionTextView(from product: Product) {
        productDescriptionTextView.text = product.description
    }
}

//MARK: - Networking
extension ProductDetailViewController {

    private func fetchProductDetail() {
        guard let productId = productId else {
            return
        }
        
        NetworkingAPI.ProductDetailQuery.request(session: URLSession.shared,
                                                 productId: productId) {
            
            result in
            
            switch result {
            case .success(let data):
                guard let product = NetworkingAPI.ProductDetailQuery.decode(data: data) else {
                    print(OpenMarketError.decodingFail("Data", "etworkingAPI.ProductDetailQuery.Response"))
                    return
                }
                DispatchQueue.main.async {
                    self.update(from: product)
                }
            case .failure(let error):
                print(error.description)
            }
        }
    }
    
    private func update(from product: Product) {
        updateNavigationTitle(from: product)
        updateImageStackView(from: product)
        updateProductTitleLabel(from: product)
        updateProductStockLabel(from: product)
        updateProductPriceLabel(from: product)
        updateProductDescriptionTextView(from: product)
    }
}