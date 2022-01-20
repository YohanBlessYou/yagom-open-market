import UIKit

class CollectionViewListCell: UICollectionViewListCell {
    
    enum Attribute {
        static let largeSpacing: CGFloat = 10
        static let smallSpacing: CGFloat = 5
    }
    
    typealias Product = NetworkingAPI.ProductListQuery.Response.Page
    
    private var activityIndicator: UIActivityIndicatorView!
    private var imageView: UIImageView!
    private var nameLabel: UILabel!
    private var priceLabel: UILabel!
    private var labelStackView: UIStackView!
    private var stockLabel: UILabel!
    private var chevronButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createAllComponents()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateAllComponents(from product: Product) {
        updateImageView(from: product)
        updateNameLabel(from: product)
        updatePriceLabel(from: product)
        updateStockLabel(from: product)
    }
    
    private func createAllComponents() {
        createActivityIndicator()
        createImageView()
        createNameLabel()
        createPriceLabel()
        createLabelStackView()
        createStockLabel()
        createChevronButton()
    }

    private func configureLayout() {
        configureMainViewLayout()
        configureActivityIndicatorLayout()
        configureImageViewLayout()
        configureLabelStackViewLayout()
        configureStockLabelLayout()
        configureChevronButtonLayout()
    }
    
    private func configureMainViewLayout() {
        contentView.addSubview(activityIndicator)
        contentView.addSubview(imageView)
        contentView.addSubview(labelStackView)
        contentView.addSubview(stockLabel)
        contentView.addSubview(chevronButton)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualTo: activityIndicator.heightAnchor,
                                                constant: Attribute.largeSpacing * 2),
            heightAnchor.constraint(greaterThanOrEqualTo: imageView.heightAnchor,
                                                constant: Attribute.largeSpacing * 2)
        ])
    }
}

//MARK: - ActivityIndicator
extension CollectionViewListCell {
    
    enum AcitivityIndicatorAttribute {
        static let spacing: CGFloat = 5
        static let fractionalWidth: CGFloat = 0.2
        static let aspectRatio: CGFloat = 1.0
    }
    
    private func createActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
    }
    
    private func configureActivityIndicatorLayout() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                       constant: Attribute.largeSpacing),
            activityIndicator.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                                     multiplier: AcitivityIndicatorAttribute.fractionalWidth),
            activityIndicator.heightAnchor.constraint(equalTo: activityIndicator.widthAnchor,
                                                      multiplier: AcitivityIndicatorAttribute.aspectRatio),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

//MARK: - ImageView
extension CollectionViewListCell {
    
    enum ImageViewAttribute {
        static let spacing: CGFloat = 5
        static let fractionalWidth: CGFloat = 0.2
        static let aspectRatio: CGFloat = 1.0
    }
    
    private func createImageView() {
        imageView = UIImageView()
    }
    
    private func updateImageView(from product: Product) {
        ImageLoader.load(from: product.thumbnail) { (result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.sync {
                    self.imageView.image = UIImage(data: data)
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func configureImageViewLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                       constant: Attribute.largeSpacing),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor,
                                             multiplier: ImageViewAttribute.fractionalWidth),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor,
                                              multiplier: ImageViewAttribute.aspectRatio),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

//MARK: - NameLabel
extension CollectionViewListCell {
    
    enum NameLabelAttribute {
        static let textStyle: UIFont.TextStyle = .title3
        static let fontColor: UIColor = .black
    }
    
    private func createNameLabel() {
        nameLabel = UILabel()
        nameLabel.adjustsFontForContentSizeCategory = true
    }
    private func updateNameLabel(from product: Product) {
        let result = NSMutableAttributedString(string: product.name)
        result.adjustBold()
        result.changeColor(to: NameLabelAttribute.fontColor)
        result.adjustDynamicType(textStyle: NameLabelAttribute.textStyle)
        
        nameLabel.attributedText = result
    }
}

//MARK: - PriceLabel
extension CollectionViewListCell {
    
    enum PriceLabelAttribute {
        static let textStyle: UIFont.TextStyle = .callout
        static let originalPriceFontColor: UIColor = .red
        static let bargainPriceFontColor: UIColor = .systemGray
    }
    
    private func createPriceLabel() {
        priceLabel = UILabel()
        priceLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func updatePriceLabel(from product: Product) {
        let blank = NSMutableAttributedString(string: " ")
        let currency = NSMutableAttributedString(string: product.currency.rawValue)
        let originalPrice = NSMutableAttributedString(string: product.price.description)
        originalPrice.adjustDecimal()
        let bargainPrice = NSMutableAttributedString(string: product.bargainPrice.description)
        bargainPrice.adjustDecimal()
        
        let result = NSMutableAttributedString(string: "")
        if product.price != product.bargainPrice {
            let originalPriceDescription = NSMutableAttributedString()
            originalPriceDescription.append(currency)
            originalPriceDescription.append(blank)
            originalPriceDescription.append(originalPrice)
            originalPriceDescription.adjustStrikeThrough()
            originalPriceDescription.changeColor(to: PriceLabelAttribute.originalPriceFontColor)
            
            let bargainPriceDescription = NSMutableAttributedString()
            bargainPriceDescription.append(currency)
            bargainPriceDescription.append(blank)
            bargainPriceDescription.append(bargainPrice)
            bargainPriceDescription.changeColor(to: PriceLabelAttribute.bargainPriceFontColor)
            
            result.append(originalPriceDescription)
            result.append(blank)
            result.append(bargainPriceDescription)
        } else {
            let bargainPriceDescription = NSMutableAttributedString()
            bargainPriceDescription.append(currency)
            bargainPriceDescription.append(blank)
            bargainPriceDescription.append(bargainPrice)
            bargainPriceDescription.changeColor(to: PriceLabelAttribute.bargainPriceFontColor)

            result.append(bargainPriceDescription)
        }
        
        result.adjustDynamicType(textStyle: PriceLabelAttribute.textStyle)
        priceLabel.attributedText = result
    }
}

//MARK: - LabelStackView
extension CollectionViewListCell {

    private func createLabelStackView() {
        labelStackView = UIStackView()
        labelStackView.axis = .vertical
        labelStackView.distribution = .fillEqually
    }
    
    private func configureLabelStackViewLayout() {
        labelStackView.addArrangedSubview(nameLabel)
        labelStackView.addArrangedSubview(priceLabel)
        labelStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: activityIndicator.trailingAnchor,
                                                    constant: Attribute.smallSpacing),
            labelStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,
                                                    constant: Attribute.smallSpacing),
            labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                constant: Attribute.largeSpacing),
            labelStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                constant: -1 * Attribute.largeSpacing)
        ])
    }
}

//MARK: - StockLabel
extension CollectionViewListCell {
    
    enum StockLabelAttribute {
        static let textStyle: UIFont.TextStyle = .callout
        static let stockFontColor: UIColor = .systemGray
        static let soldoutFontColor: UIColor = .orange
    }
    
    private func createStockLabel() {
        stockLabel = UILabel()
        stockLabel.adjustsFontForContentSizeCategory = true
    }
    
    private func updateStockLabel(from product: Product) {
        let result = NSMutableAttributedString()
        if product.stock == 0 {
            result.append(NSAttributedString(string: "품절"))
            result.changeColor(to: StockLabelAttribute.soldoutFontColor)
        } else {
            result.append(NSAttributedString(string: "잔여수량: \(product.stock)"))
            result.changeColor(to: StockLabelAttribute.stockFontColor)
        }
        
        result.adjustDynamicType(textStyle: StockLabelAttribute.textStyle)
        stockLabel.attributedText = result
    }
    
    private func configureStockLabelLayout() {
        stockLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stockLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                            constant: Attribute.largeSpacing),
            stockLabel.trailingAnchor.constraint(equalTo: chevronButton.leadingAnchor,
                                                constant: -1 * Attribute.largeSpacing),
        ])
    }
}

//MARK: - ChevronButton
extension CollectionViewListCell {
    
    private func createChevronButton() {
        chevronButton = UIButton()
        chevronButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        chevronButton.tintColor = .systemGray
    }
    
    private func configureChevronButtonLayout() {
        chevronButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chevronButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                    constant: -1 * Attribute.largeSpacing),
            chevronButton.centerYAnchor.constraint(equalTo: stockLabel.centerYAnchor)
        ])
    }
}
