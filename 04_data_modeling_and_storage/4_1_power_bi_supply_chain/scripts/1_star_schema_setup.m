/* Dim_Customer */

let
    Source = DataCoSupplyChainDataset,
    #"Removed Other Columns" = Table.SelectColumns(Source,{"Customer City", "Customer Country", "Customer Fname", "Customer Id", "Customer Lname", "Customer Segment", "Customer State", "Customer Street", "Customer Zipcode"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Removed Other Columns",{"Customer Id", "Customer Fname", "Customer Lname", "Customer Segment", "Customer Street", "Customer City", "Customer State", "Customer Country", "Customer Zipcode"}),
    #"Removed Duplicates" = Table.Distinct(#"Reordered Columns", {"Customer Id"})
in
    #"Removed Duplicates"

/* Dim_Product */

let
    Source = DataCoSupplyChainDataset,
    #"Removed Other Columns" = Table.SelectColumns(Source,{"Category Name", "Department Id", "Department Name", "Product Card Id", "Product Category Id", "Product Name", "Product Price", "Product Status"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Removed Other Columns",{"Product Card Id", "Product Category Id", "Product Name", "Product Price", "Product Status", "Category Name", "Department Id", "Department Name"}),
    #"Changed Type" = Table.TransformColumnTypes(#"Reordered Columns",{{"Product Status", type text}}),
    #"Replaced Value" = Table.ReplaceValue(#"Changed Type","0","Available",Replacer.ReplaceText,{"Product Status"}),
    #"Removed Duplicates" = Table.Distinct(#"Replaced Value")
in
    #"Removed Duplicates"

/* Fact_OrderItems */

let
    Source = DataCoSupplyChainDataset,
    #"Removed Columns" = Table.RemoveColumns(Source,{"Category Id", "Category Name", "Customer City", "Customer Country", "Customer Email", "Customer Fname", "Customer Id", "Customer Lname", "Customer Password", "Customer Segment", "Customer State", "Customer Street", "Customer Zipcode", "Department Id", "Department Name", "Latitude", "Longitude", "Order Zipcode", "Product Card Id", "Product Category Id", "Product Description", "Product Image", "Product Name", "Product Price", "Product Status"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Removed Columns",{"Order Item Id", "Order Id", "order date (DateOrders)", "shipping date (DateOrders)", "Order Customer Id", "Order Item Cardprod Id", "Type", "Days for shipping (real)", "Days for shipment (scheduled)", "Benefit per order", "Sales per customer", "Delivery Status", "Late_delivery_risk", "Market", "Order City", "Order Country", "Order Region", "Order State", "Order Status", "Shipping Mode", "Order Item Discount", "Order Item Discount Rate", "Order Item Product Price", "Order Item Profit Ratio", "Order Item Quantity", "Sales", "Order Item Total", "Order Profit Per Order"})
in
    #"Reordered Columns"
