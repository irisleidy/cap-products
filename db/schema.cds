namespace com.dev;

using {
    cuid,
    managed
} from '@sap/cds/common';

type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
}

entity Product : cuid, managed {
    key ID                 : UUID;
        Name               : localized String not null;
        Description        : localized String;
        ImageUrl           : String;
        ReleaseDate        : DateTime default $now;
        DiscontinuedDate   : DateTime;
        Price              : Dec;
        Height             : String;
        Width              : Decimal(16, 2);
        Depth              : Decimal(16, 2);
        Quantity           : Decimal(16, 2);
        Supplier           : Association to one Suppliers;
        UnitOfMeasure      : Association to one UnitOfMeasures;
        Currency           : Association to one Currencies;
        DimensionUnit      : Association to one DimensionUnits;
        Category           : Association to one Categories;
        SalesData          : Association to many SalesData
                                 on SalesData.Product = $self;
        Reviews            : Association to many ProductReview
                                 on Reviews.Product = $self;
        PriceCondition     : String(2);
        PriceDetermination : String(3);
}

entity Categories {
    key ID   : String(1);
        Name : localized String;
}

entity StockAvailability {
    key ID          : Integer;
        Description : localized String;
        Product     : Association to one Product;
}

entity Currencies {
    key ID          : String(3);
        Description : localized String;
}

entity UnitOfMeasures {
    key ID          : String(2);
        Description : localized String;
}

entity DimensionUnits {
    key ID          : String(2);
        Description : localized String;
}

entity ProductReview : cuid, managed {
    Name    : String;
    Rating  : Integer;
    Comment : String;
    Product : Association to one Product;
}

entity Orders : cuid {
    Date     : Date;
    Customer : String;
    Item     : Composition of many OrderItems
                   on Item.Order = $self;
}

entity OrderItems : cuid {
    Order    : Association to one Orders;
    Product  : Association to one Product;
    Quantity : Integer;
}

entity Suppliers : cuid, managed {
    Name    : localized String not null;
    Address : Address;
    Email   : String;
    Phone   : String;
    Fax     : String;
    Product : Association to many Product
                  on Product.Supplier = $self;
}

entity Months {
    key ID               : String(2);
        Description      : localized String;
        ShortDescription : localized String(3);
}

entity SalesData : cuid, managed {
    DeliveryDate  : DateTime;
    Revenue       : Decimal(16, 2);
    Product       : Association to one Product;
    Currency      : Association to one Currencies;
    DeliveryMonth : Association to one Months;
}

type Dec  : Decimal(16, 2);
type Name : String(50);


entity AverageRating                 as
    select from ProductReview {
        Product.ID  as ProductId,
        avg(Rating) as AverageRating : Decimal(16, 2)
    }
    group by
        Product.ID;

entity Products                      as
    select from Product
    mixin {
        ToStockAvailability : Association to StockAvailability
                                  on ToStockAvailability.ID = $projection.StockAvailability;
        ToAverageRating     : Association to AverageRating
                                  on ToAverageRating.ProductId = ID;
    }
    into {
        *,
        ToAverageRating.AverageRating as Rating,
        case
            when
                Quantity >= 8
            then
                3
            when
                Quantity > 0
            then
                2
            else
                1
        end                           as StockAvailability : Integer,
        ToStockAvailability
    };

entity SelProducts1                  as
    select from Products
    left join ProductReview
        on Products.Name = ProductReview.Name
    {
        ProductReview.Rating,
        Products.Name,
        sum(Price) as TotalPrice
    }
    group by
        ProductReview.Rating,
        Products.Name
    order by
        Rating;

entity ProjProducts                  as projection on Products {
    ReleaseDate,
    Name
};

/*entity ParamProducts(pName : String) as
    select from Products {
        Name,
        Price,
        Quantity
    }
    where
        Name = : pName;*/

extend projection Products with {
    PriceCondition     : String(2),
    PriceDetermination : String(3),
};

context reports {
    entity AverageRating as
        select from dev.ProductReview {
            Product.ID  as ProductId,
            avg(Rating) as AverageRating : Decimal(16, 2)
        }
        group by
            Product.ID;
}
