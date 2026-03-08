/*
JC-202102-citibike-tripdata.csv has a different schema than the previous two files. The script created ID Mapping Table:
*/  

let
    Source = Staging_New_202102,
    #"Removed Columns" = Table.RemoveColumns(Source,{"ride_id", "started_at", "ended_at", "end_station_name", "end_station_id", "start_lat", "start_lng", "end_lat", "end_lng", "member_casual"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Columns", {"start_station_name"})
in
    #"Removed Duplicates"

/*
JC-202012-citibike-tripdata.csv is the file name for the December 2020 Citibike trip data. The script performs the following steps:
*/

let
    Source = Csv.Document(File.Contents("C:\Path\To\Your\Data\JC-202012-citibike-tripdata.csv"),[Delimiter=",", Columns=15, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"tripduration", Int64.Type}, {"starttime", type datetime}, {"stoptime", type datetime}, {"start station id", Int64.Type}, {"start station name", type text}, {"start station latitude", type number}, {"start station longitude", type number}, {"end station id", Int64.Type}, {"end station name", type text}, {"end station latitude", type number}, {"end station longitude", type number}, {"bikeid", Int64.Type}, {"usertype", type text}, {"birth year", Int64.Type}, {"gender", Int64.Type}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type",{"tripduration", "bikeid", "birth year", "gender"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"starttime", "started_at"}, {"stoptime", "ended_at"}, {"start station name", "start_station_name"}, {"start station id", "start_station_id"}, {"start station latitude", "start_lat"}, {"start station longitude", "start_lng"}, {"end station name", "end_station_name"}, {"end station id", "end_station_id"}, {"end station latitude", "end_lat"}, {"end station longitude", "end_lng"}, {"usertype", "member_casual"}}),
    #"Replaced Value" = Table.ReplaceValue(#"Renamed Columns","Subscriber","member",Replacer.ReplaceText,{"member_casual"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value","Customer","casual",Replacer.ReplaceText,{"member_casual"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Replaced Value1",{{"start_station_id", type text}}),
    #"Merged Queries" = Table.NestedJoin(#"Changed Type1", {"start_station_name"}, Start_Station_ID_Mapping, {"start_station_name"}, "Station_ID_Mapping", JoinKind.LeftOuter),
    #"Expanded Station_ID_Mapping" = Table.ExpandTableColumn(#"Merged Queries", "Station_ID_Mapping", {"start_station_id"}, {"start_station_id.1"}),
    #"Removed Columns1" = Table.RemoveColumns(#"Expanded Station_ID_Mapping",{"start_station_id"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Removed Columns1",{"started_at", "ended_at", "start_station_id.1", "start_station_name", "start_lat", "start_lng", "end_station_id", "end_station_name", "end_lat", "end_lng", "member_casual"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Reordered Columns",{{"start_station_id.1", "start_station_id"}}),
    #"Merged Queries1" = Table.NestedJoin(#"Renamed Columns1", {"end_station_name"}, Start_Station_ID_Mapping, {"start_station_name"}, "Station_ID_Mapping", JoinKind.LeftOuter),
    #"Expanded Station_ID_Mapping1" = Table.ExpandTableColumn(#"Merged Queries1", "Station_ID_Mapping", {"start_station_id"}, {"start_station_id.1"}),
    #"Removed Columns2" = Table.RemoveColumns(#"Expanded Station_ID_Mapping1",{"end_station_id"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Removed Columns2",{{"start_station_id.1", "end_station_id"}}),
    #"Reordered Columns1" = Table.ReorderColumns(#"Renamed Columns2",{"started_at", "ended_at", "start_station_id", "start_station_name", "start_lat", "start_lng", "end_station_id", "end_station_name", "end_lat", "end_lng", "member_casual"}),
    #"Filtered Rows" = Table.SelectRows(#"Reordered Columns1", each ([end_station_id] <> null))
in
    #"Filtered Rows"

/*
JC-202101-citibike-tripdata.csv is the file name for the January 2021 Citibike trip data. The script performs the following steps:
*/ 

let
    Source = Csv.Document(File.Contents("C:\Path\To\Your\Data\JC-202101-citibike-tripdata.csv"),[Delimiter=",", Columns=15, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"tripduration", Int64.Type}, {"starttime", type datetime}, {"stoptime", type datetime}, {"start station id", Int64.Type}, {"start station name", type text}, {"start station latitude", type number}, {"start station longitude", type number}, {"end station id", Int64.Type}, {"end station name", type text}, {"end station latitude", type number}, {"end station longitude", type number}, {"bikeid", Int64.Type}, {"usertype", type text}, {"birth year", Int64.Type}, {"gender", Int64.Type}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type",{"tripduration", "bikeid", "birth year", "gender"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"stoptime", "ended_at"}, {"starttime", "started_at"}, {"start station name", "start_station_name"}, {"start station id", "start_station_id"}, {"start station latitude", "start_lat"}, {"start station longitude", "start_lng"}, {"end station id", "end_station_id"}, {"end station name", "end_station_name"}, {"end station latitude", "end_lat"}, {"end station longitude", "end_lng"}, {"usertype", "member_casual"}}),
    #"Replaced Value" = Table.ReplaceValue(#"Renamed Columns","Subscriber","member",Replacer.ReplaceText,{"member_casual"}),
    #"Replaced Value1" = Table.ReplaceValue(#"Replaced Value","Customer","casual",Replacer.ReplaceText,{"member_casual"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Replaced Value1",{{"start_station_id", type text}}),
    #"Merged Queries" = Table.NestedJoin(#"Changed Type1", {"start_station_name"}, Start_Station_ID_Mapping, {"start_station_name"}, "Station_ID_Mapping", JoinKind.LeftOuter),
    #"Expanded Station_ID_Mapping" = Table.ExpandTableColumn(#"Merged Queries", "Station_ID_Mapping", {"start_station_id"}, {"Station_ID_Mapping.start_station_id"}),
    #"Removed Columns1" = Table.RemoveColumns(#"Expanded Station_ID_Mapping",{"start_station_id"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Removed Columns1",{"started_at", "ended_at", "Station_ID_Mapping.start_station_id", "start_station_name", "start_lat", "start_lng", "end_station_id", "end_station_name", "end_lat", "end_lng", "member_casual"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Reordered Columns",{{"Station_ID_Mapping.start_station_id", "start_station_id"}}),
    #"Merged Queries1" = Table.NestedJoin(#"Renamed Columns1", {"end_station_name"}, Start_Station_ID_Mapping, {"start_station_name"}, "Station_ID_Mapping", JoinKind.LeftOuter),
    #"Expanded Station_ID_Mapping1" = Table.ExpandTableColumn(#"Merged Queries1", "Station_ID_Mapping", {"start_station_id"}, {"start_station_id.1"}),
    #"Removed Columns2" = Table.RemoveColumns(#"Expanded Station_ID_Mapping1",{"end_station_id"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Removed Columns2",{{"start_station_id.1", "end_station_id"}}),
    #"Reordered Columns1" = Table.ReorderColumns(#"Renamed Columns2",{"started_at", "ended_at", "start_station_id", "start_station_name", "start_lat", "start_lng", "end_station_id", "end_station_name", "end_lat", "end_lng", "member_casual"}),
    #"Filtered Rows" = Table.SelectRows(#"Reordered Columns1", each ([end_station_id] <> null))
in
    #"Filtered Rows"

/*
JC-202102-citibike-tripdata.csv is the file name for the February 2021 Citibike trip data. The script performs the following steps:
*/ 

let
    Source = Csv.Document(File.Contents("C:\Path\To\Your\Data\JC-202102-citibike-tripdata.csv"),[Delimiter=",", Columns=13, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"ride_id", type text}, {"rideable_type", type text}, {"started_at", type datetime}, {"ended_at", type datetime}, {"start_station_name", type text}, {"start_station_id", type text}, {"end_station_name", type text}, {"end_station_id", type text}, {"start_lat", type number}, {"start_lng", type number}, {"end_lat", type number}, {"end_lng", type number}, {"member_casual", type text}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type",{"rideable_type"}),
    #"Filtered Rows" = Table.SelectRows(#"Removed Columns", each ([end_station_id] <> ""))
in
    #"Filtered Rows"


/*
Append the files together to create a single dataset for analysis. The script performs the following steps:
*/ 

let
    Source = Table.Combine({Staging_Old_202012, Staging_Old_202101, Staging_New_202102})
in
    Source