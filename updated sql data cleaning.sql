--CLEANING DATA IN SQL QUERIES

--IMPORT DATA AMD RUN SELECT QUERIES

USE portfolioprojects;

Select *
From dbo.temp_table;

--CREATE A TEMP TABLE
----Create temporary table to prevent loss of delicate data from the original dataset

DROP TABLE  IF EXISTS temp_table;
SELECT * INTO temp_table
	FROM dbo.nashvillehousing;

SELECT * FROM temp_table

--STANDARDIZE THE DATA

select column_name, DATA_TYPE from INFORMATION_SCHEMA.columns;
select * from temp_table;

alter table temp_table
alter column SaleDate Date;

alter table temp_table
alter column uniqueid int;

alter table temp_table
alter column yearbuilt int;

alter table temp_table
alter column bedrooms int;

alter table temp_table
alter column fullbath int;

alter table temp_table
alter column halfbath int;

--DEALING WITH NULL VALUES AND DUPLICATES

Select *
From temp_table
Where PropertyAddress is null
order by ParcelID;


Select a.ParcelID as ParcelID_a, a.PropertyAddress as PropertyAddress_a, b.ParcelID as ParcelID_b, b.PropertyAddress as PropertyAddress_b, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects.dbo.temp_table a
JOIN PortfolioProjects.dbo.temp_table b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From portfolioprojects.dbo.temp_table a
JOIN portfolioprojects.dbo.temp_table b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--SPLITTING ADDRESSES INTO SEPARATE COLUMNS

----Separate PropertyAddress column
Select PropertyAddress
From portfolioprojects.dbo.temp_table

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City

From portfolioprojects.dbo.temp_table

ALTER TABLE temp_table
Add PropertyAddresses Nvarchar(255);

Update temp_table
SET PropertyAddresses = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE temp_table
Add PropertyCity Nvarchar(255);

Update temp_table
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

----Separate OwnerAddress column

Select OwnerAddress
From portfolioprojects.dbo.temp_table


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From portfolioprojects.dbo.temp_table



ALTER TABLE temp_table
Add OwnerAddresses Nvarchar(255);

Update temp_table
SET OwnerAddresses = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE temp_table
Add OwnerCity Nvarchar(255);

Update temp_table
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE temp_table
Add OwnerState Nvarchar(255);

Update temp_table
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


---- CHANGING Y AND N TO 'YES' AND 'NO' IN 'SoldAsVacant'

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolioprojects.dbo.temp_table
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From portfolioprojects.dbo.temp_table


Update temp_table
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--REMOVING DUPLICATES
---- using ROW_NUMBER function to assigns a sequential rank number to each new record in a partition.
WITH table_row AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) num_row

From portfolioprojects.dbo.temp_table
)
Select *
From table_row
Where num_row > 1
Order by PropertyAddress


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From portfolioprojects.dbo.temp_table
)
DELETE
From RowNumCTE
Where row_num > 1


--DELETING UNUSED COLUMNS

Select *
From portfolioprojects.dbo.temp_table


ALTER TABLE PortfolioProject.dbo.temp_table
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress