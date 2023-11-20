using com.dev as dev from '../db/schema';

/*service CatalogService {
    entity Products as projection on dev.Products;
    entity Suppliers as projection on dev.Suppliers;
    entity Currency as projection on dev.Currencies;
    entity DimensionUnit as projection on dev.DimensionUnits;
    entity Category as projection on dev.Categories;
    entity SalesData as projection on dev.SalesData;
    entity Reviews as projection on dev.ProductReview;
    entity UnitOfMeasure as projection on dev.UnitOfMeasures;
    entity Months as projection on dev.Months;
    entity Order as projection on dev.Orders;
    entity OrderItem as projection on dev.OrderItems;
}*/

//using com.training as training from '../db/training';

//cds deploy --to sqlite:db/Alberto
//http://erp13.sap4practice.com:9037/sap/opu/odata/sap/YSAPUI5_SRV_01/$metadata
//npm i @sap-cloud-sdk/http-client
//@cap-js/graphql
//cds-swagger-ui-express

define service CatalogService {

    entity Products          as
        select from dev.Products {
            ID,
            Name          as ProductName     @mandatory,
            Description                      @mandatory,
            ImageUrl,
            ReleaseDate,
            DiscontinuedDate,
            @mandatory
            Price,
            Height,
            Width,
            Depth,
            @(
                mandatory,
                assert.range: [
                    0.00,
                    20.00
                ]
            )
            Quantity,
            UnitOfMeasure as ToUnitOfMeasure @mandatory,
            Currency      as ToCurrency      @mandatory,
            Currency.ID   as CurrencyId,
            Category      as ToCategory      @mandatory,
            Category.ID   as CategoryId,
            Category.Name as Category        @readonly,
            DimensionUnit as ToDimensionUnit,
            SalesData,
            Supplier,
            Reviews,
            Rating,
            StockAvailability,
            ToStockAvailability
        };

    @readonly
    entity Supplier          as
        select from dev.Suppliers {
            ID,
            Name,
            Email,
            Phone,
            Fax,
            Product as ToProduct
        };

    entity Reviews           as
        select from dev.ProductReview {
            ID,
            Name,
            Rating,
            Comment,
            createdAt,
            Product as ToProduct
        };

    @readonly
    entity SalesData         as
        select from dev.SalesData {
            ID,
            DeliveryDate,
            Revenue,
            Currency.ID               as CurrencyKey,
            DeliveryMonth.ID          as DeliveryMonthId,
            DeliveryMonth.Description as DeliveryMonth,
            Product                   as ToProduct
        };

    @readonly
    entity StockAvailability as
        select from dev.StockAvailability {
            ID,
            Description,
            Product as ToProduct
        };

    @readonly
    entity VH_Categories     as
        select from dev.Categories {
            ID   as Code,
            Name as Text
        };

    @readonly
    entity VH_Currencies     as
        select from dev.Currencies {
            ID          as Code,
            Description as Text
        };

    @readonly
    entity VH_DimensionUnits as
        select from dev.DimensionUnits {
            ID          as Code,
            Description as Text
        };
}

define service Report {

    entity AverageRating     as projection on dev.AverageRating;

    entity EntityCasting     as
        select
            cast(
                Price as      Integer
            )     as Price,
            Price as Price2 : Integer
        from dev.Products;

    entity EntityExists      as
        select from dev.Products {
            Name
        }
        where
            exists Supplier[Name = 'Exotic Liquids'];

}

define service Util {

    entity SuppliersProduct  as
        select from dev.Product[Name = 'Bread']{
            *,
            Product.Name,
            Description,
            Supplier.Address
        }
        where
            Supplier.Address.PostalCode = 98074;

    entity SuppliersToSales  as
        select
            Supplier.Email,
            Category.Name,
            SalesData.Currency.ID,
            SalesData.Currency.Description
        from dev.Products;

    entity EntityInfix       as
        select Supplier[Name = 'Exotic Liquids'].Phone from dev.Product
        where
            Product.Name = 'Bread';

    entity EntityJoin        as
        select Phone from dev.Product
        left join dev.Suppliers as supp
            on(
                supp.ID = Product.Supplier.ID
            )
            and supp.Name = 'Exotic Liquids'
        where
            Product.Name = 'Bread';
}
