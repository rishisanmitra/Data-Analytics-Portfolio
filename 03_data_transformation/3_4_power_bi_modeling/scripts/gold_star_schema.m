/*
This query creates the Fact Table in theeGold Star Schema by removing unnecessary columns from the Silver_Citibike_Trips table.
*/

let
    Source = Silver_Citibike_Trips,
    #"Removed Columns" = Table.RemoveColumns(Source,{"start_station_name", "start_lat", "start_lng", "end_station_name", "end_lat", "end_lng"})
in
    #"Removed Columns"

/*
This query creates the Dimension Table in the Gold Star Schema by selecting only the necessary columns from the Silver_Citibike_Trips table and removing duplicates.
*/  

let
    Source = Silver_Citibike_Trips,
    #"Removed Other Columns" = Table.SelectColumns(Source,{"start_station_id", "start_station_name", "start_lat", "start_lng"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns", {"start_station_id"}),
    #"Filtered Rows" = Table.SelectRows(#"Removed Duplicates", each true)
in
    #"Filtered Rows"