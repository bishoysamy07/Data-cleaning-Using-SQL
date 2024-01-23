select * from Nashville_Housingnew

-- The new column is what we want the SaleDate to look like.

UPDATE Nashville_Housingnew

SET SaleDate = CONVERT (Date, SaleDate)

-- Use UPDATE to change SaleDate to Date Format.

-- Add a new column with the standardized date. Use ALTER TABLE, then UPDATE.

ALTER TABLE Nashville_Housingnew

Add SaleDateConverted Date;

UPDATE Nashville_Housingnew

SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Check to see if new column SaleDateConverted is correct.

SELECT SaleDateConverted, CONVERT(Date, SaleDate)

from Nashville_Housingnew

/* Let's look at the Property Address Data */



select PropertyAddress 
from Nashville_Housingnew
where PropertyAddress is null

/* I noticed there are nulls. Let's investigate. */

select * 
from Nashville_Housingnew
order by ParcelID

-- I notice the same ParcelID and PropertyAddress are listed for different UniqueIDs.

-- Join where the ParcelIDs are the same but the UniqueIDs are different, and look where the PropertyAddress is null.

-- Use ISNULL to create new column that reflects where a.Property was null and have it input b.PropertyAddress


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housingnew a
join Nashville_Housingnew b
on a.ParcelID= b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-- Update PropertyAddress column using alias a.

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Nashville_Housingnew a
join Nashville_Housingnew b
on a.ParcelID= b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


/* Split PropertyAddress into separate columns for address and city Using SUBSTRING and CHARINDEX */

select subSTRING(PropertyAddress,1,ChARINDEX(',',PropertyAddress)-1) as address,
       SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City 
from Nashville_Housingnew


-- Take the PropertyAddress at position 1 until the comma ','. Then to remove the comma, -1. Name the column 'Address'

-- Take the PropertyAddress until the comma's position. Then to remove the comma, -1. Name the column 'City'

-- Run query to check accuracy


Alter table Nashville_Housingnew
Add SplitProportyAddress NvarChar(255);

-- Add a column for the split address.


update Nashville_Housingnew
Set SplitProportyAddress= subSTRING(PropertyAddress,1,ChARINDEX(',',PropertyAddress)-1)

-- Input the data for the split address column.

Alter table Nashville_Housingnew

-- Add a column for the split city.

Add SplitProportyCity NvarChar(255);

update Nashville_Housingnew
set SplitProportyCity = subString(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

-- Input the data for the split city column.

/* Split OwnerAddress into separate columns for address, city, and state. */


select PARSENAME(replace(OwnerAddress,',','.'),3),
       ParseName(replace(OwnerAddress,',','.'),2),
	   ParseName(replace(OwnerAddress,',','.'),1)
from Nashville_Housingnew

Alter table Nashville_Housingnew
Add SplitOwnerAddress NvarChar(255)

-- Add a column for SplitOwnerAddress.

Update Nashville_Housingnew
Set SplitOwnerAddress= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

-- Input the data for SplitOwnerAddress column

Alter table Nashville_Housingnew
Add SplitOwnerCity NvarChar(255)

-- Add a column for SplitOwnerCity.



Update Nashville_Housingnew
Set SplitOwnerCity= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

-- Input the data for SplitOwnerCity column.

Alter table Nashville_Housingnew
Add SplitOwnerState NvarChar(255)

-- Add a column for SplitOwnerState.

Update Nashville_Housingnew
Set SplitOwnerState= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Input the data for SplitOwnerState column.

/* Let's look at the SoldAsVacant column. */

select DISTINCT(SoldAsVacant),count(SoldAsVacant)
from Nashville_Housingnew
group by SoldAsVacant
order by 2

/* Update the Y/N to show as Yes/No in the Sold as Vacant field. */

select SoldAsVacant, 
       case
	   when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'NO'
	   else SoldAsVacant
	   end
from Nashville_Housingnew


-- Since query works, we can update accordingly.

UPDATE Nashville_Housingnew
set SoldAsVacant= case
	   when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'NO'
	   else SoldAsVacant
	   end

/* Check for duplicates. */
with RowNumCTE AS (select *, ROW_NUMBER() over(partition by ParcelID,PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) as row_num   
from Nashville_Housingnew)

select *
from RowNumCTE
where row_num >1

with RowNumCTE AS (select *, ROW_NUMBER() over(partition by ParcelID,PropertyAddress, SaleDate, SalePrice, LegalReference order by UniqueID) as row_num   
from Nashville_Housingnew)

delete
from RowNumCTE
where row_num >1

SELECT *

FROM Nashville_Housingnew

/* Delete unused columns. */

ALTER TABLE Nashville_Housingnew

DROP COLUMN OwnerAddress, PropertyAddress

