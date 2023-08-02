/*

Cleaning data in SQL Queries

*/
SELECT *
FROM PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

SELECT SaleDate,CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing					--not updating in table
SET SaleDate = CONVERT(Date,SaleDate)



ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

	--checking for if any Null values present in PropertyAddress
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL				--there are 29 duplicates present but that row has only propertyaddress has NULL,
											--but if we delete means others information will lost

SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID							--some rows contains, Same ParcelID in both rows, and others columns like propertyAddress, OwnerAddress and many others are excatly same ,
											--If one row contain PropertyAddress is NULL, let's populate other's ProperyAddress INTO this row

	--Using SELF JOIN
			--for propertAddress which contains Null values
			--joining table with itself, (if parcelID of one row = parcel ID of other row) THEN propertAddress=propertyaddress
			--here, UniqueID is diffrent for each row, let's Ignore that one



SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress iS NULL
										--we need to populate b.propertyaddress into a.propertyaddress

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)			
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b						--updated b.propertyaddress into a.propertyaddress WHERE NULL values present in a.propertyaddress
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress iS NULL

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing							--Checking for null values , now no null values
WHERE PropertyAddress IS NULL



--Breaking PropertyAddress INTO individual columns (ADDRESS, CITY, STATE)
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing				--1808  FOX CHASE DR, GOODLETTSVILLE
													--here ,(delimeter) present which separate columns
		
								--we are using SUBSTRING & CHARINDEX
								--SUBSTRING(expression,starting_postion int, length int)RETURNS <string>
								--CHARINDEX->searching for specific value and returns int

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing								--,(delimeter) is coming at the end, we need to get rid off it


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address,
CHARINDEX(',',PropertyAddress)
FROM PortfolioProject..NashvilleHousing						--1808  FOX CHASE DR,	19(this means ',' is present at the 19th position) so we need get data (19-1) data length position 
															--SUBSTRING(,,CHARINDEX(',',PropertyAddress)) acts like length int in substring

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
FROM PortfolioProject..NashvilleHousing								--,is removed


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) Address
FROM PortfolioProject..NashvilleHousing																--SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress) for next position 
									--now we cleaned the PropertyAddress column and now we have to create two separate columns for these data and we need to t data into these columns and update these columns into table


ALTER TABLE PortfolioProject..NashvilleHousing	
ADD PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)



ALTER TABLE PortfolioProject..NashvilleHousing	
ADD PropertySplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))



SELECT *
FROM PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------------------
--Cleaning OwnerAddress

						
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing							--ex:1808  FOX CHASE DR, GOODLETTSVILLE, TN						(address,city,state)


				--using PARSENAME		--useful when delimated by specific value
										--ParseName is useul when we have Periods(.)
										--returns nvarchar
			
SELECT
PARSENAME(OwnerAddress,1)
FROM PortfolioProject..NashvilleHousing					--so we need to Replacing Periods(.) into (,)
												


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing					--TN is returned from OwnerAddress

--SELECT
--PARSENAME(REPLACE(OwnerAddress,',','.'),1),
--PARSENAME(REPLACE(OwnerAddress,',','.'),2),						--reverse order
--PARSENAME(REPLACE(OwnerAddress,',','.'),3)
--FROM PortfolioProject..NashvilleHousing	

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing				--now ownerAddress is cleaned into three columns


		--Creating columns and uploading data and Updating in table
ALTER TABLE PortfolioProject..NashvilleHousing	
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);



ALTER TABLE PortfolioProject..NashvilleHousing	
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);



ALTER TABLE PortfolioProject..NashvilleHousing	
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

																						--we splited into 3 columns address, city,state from OwnerAddress(1808  FOX CHASE DR, GOODLETTSVILLE, TN)
SELECT *																				--so that these columns are useful
FROM PortfolioProject..NashvilleHousing													


-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Changing Y and N to YES and NO in SoldAsVacant
SELECT SoldAsVacant,COUNT(SoldAsVacant)																				
FROM PortfolioProject..NashvilleHousing
Group by SoldAsVacant

		--using CASE statement to change
SELECT SoldAsVacant,
		CASE WHEN SoldAsVacant='Y' THEN 'Yes'
		     WHEN SoldAsVacant='N' THEN 'No'
			 ELSE SoldAsVacant
		END
FROM PortfolioProject..NashvilleHousing

		--Updating SoldAsVacant

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
						WHEN SoldAsVacant='N' THEN 'No'
						ELSE SoldAsVacant
				   END


---------------------------------------------------------------------------------------------------------------------
--Remove Duplicates

			--we need to Create TEMP table or CTE , and put the data, Remove Duplicates there, so that we can't delete our Actual Data.

			--First wruting CTE and then doing some Windows Function to find where are the DUPLICATES values are present


SELECT *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as Row_Num
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID
													--if rows consists SAME ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference and otherthings then They are DUPLICATES, 
													--eventhough the UniqueID is different 
													--windows are order by UniqueID and Table is order by ParcelID

													--if data gets into that window, it will assign Row_Num as 1,2,3,....in same window if rows are present, that means duplicates


		--putting into CTE
WITH RowNumCTE AS(
				SELECT *,
				ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as Row_Num
				FROM PortfolioProject..NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY ParcelID									--104 row contains Row_Num as 2(which is > 1) that means they are duplicates and we need to remove


		--Deleting rows whose Row_Num > 1
WITH RowNumCTE AS(
				SELECT *,
				ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as Row_Num
				FROM PortfolioProject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1

			--(to check for dplicates Run above CTE nd Select query)

-------------------------------------------------------------------------------------------------------------------------------------------------

--DELETE unused columns

		--we need to delete Unused,Unnecessory columns which are waste
		
		--it is better to Create VIEW, thendeleting the unused data, so that it will not affect any original data

		--but while deleting Raw data be Careful

	--Deleting PropertyAddress,OwnerAddress,SaleDate,TaxDistrict and other things which are waste

SELECT *
FROM PortfolioProject..NashvilleHousing
	
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress,OwnerAddress,SaleDate,TaxDistrict

SELECT *
FROM PortfolioProject..NashvilleHousing


--now we cleaned the data now its more useful