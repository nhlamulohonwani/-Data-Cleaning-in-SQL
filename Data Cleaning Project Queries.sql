/* 

Cleaning Data in SQL Queries

*/

Select * 
From PortifolioProject1.dbo.NashvillieHousing
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Standandize Date Format (Just changing the SaleDate)

Select SaleDate                                 -- The SaleDate column has time on the end that serves no purpose
From PortifolioProject1.dbo.NashvillieHousing

   -- We use CONVERT to remove the time, but we also create a new column (SaleDateConverted)
   Select SaleDate, CONVERT(Date,SaleDate)      
   From PortifolioProject1.dbo.NashvillieHousing

   --  Use UPDATE to change the old column to new one
 
   UPDATE NashvillieHousing               --   This does not work sometimes 20% of the time
   SET SaleDate = CONVERT(Date,SaleDate) 
 
   -- Therefore we use ALTER TABLE to create a new column and update it as we tried previously
   ALTER TABLE NashvillieHousing
   ADD SaleDateConverted DATE;

   UPDATE NashvillieHousing
   SET SaleDateConverted = CONVERT(Date,SaleDate)

   -- Then after run it to see if it worked (And it wolrks!!!)
   Select SaleDateConverted, CONVERT(Date,SaleDate)      
   From PortifolioProject1.dbo.NashvillieHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortifolioProject1.dbo.NashvillieHousing
-- Where PropertyAddress is null
order by ParcelID

   -- Self Join
   Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
   From PortifolioProject1.dbo.NashvillieHousing a
   JOIN PortifolioProject1.dbo.NashvillieHousing b
       on a.ParcelID = b.ParcelID
       AND a.[UniqueID ] <> b.[UniqueID ]
    Where a.PropertyAddress is null

    Update a
    SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
    From PortifolioProject1.dbo.NashvillieHousing a
    JOIN PortifolioProject1.dbo.NashvillieHousing b
       on a.ParcelID = b.ParcelID
       AND a.[UniqueID ] <> b.[UniqueID ]
     Where a.PropertyAddress is null


/*  Notes 
 We have null values for some of the property address. We need s 
 reference ID, so that we can replace those address, because if there is same 
 ParcelID therefore the Propert address should be the same. What we are to do is to 
 populate the null value with Property address from those that they share parcelID
- We will have to do a Self join, we will have to Join the table to itself
to see if the ParcelID values are the same, and them give them the saae propert
address. ("on a.ParcelID = b.ParcelID")
- The UniqueID is unique, therefore we can use it to distinguish the rows
- We have rows that have null Property Address but share ParcelID with other rows
that have the address.
- We use ISNULL function to check a.PropertyAddress (where it is null) and if it is null 
we populate it with b.PropertyAddress address.
- After using ISNULL the results will have a new colunm that is populated with the 
address from similar parcelID in b.PropertyAddress
- Then we use UPDATE to update the PropertyAddress in a and replace the null values
- When we run the above code to check null values, we do not get any.
- But we could have also written a string inside the null function in a case where the parcelIDs w
were not the same (ISNULL(a.PropertyAddress, "No Address")
*/


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

             ---- PropertyAddress ---
Select PropertyAddress
From PortifolioProject1.dbo.NashvillieHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortifolioProject1.dbo.NashvillieHousing

 ALTER TABLE NashvillieHousing
   ADD PropertySplitAddress Nvarchar(255);

   UPDATE NashvillieHousing
   SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

 ALTER TABLE NashvillieHousing
   ADD PropertySplitCity Nvarchar(255);

   UPDATE NashvillieHousing
   SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

   -- To see the two columns added at the end of the table
Select *
From PortifolioProject1.dbo.NashvillieHousing 

             ---- OwnerAddress ---

Select OwnerAddress
From PortifolioProject1.dbo.NashvillieHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From PortifolioProject1.dbo.NashvillieHousing

ALTER TABLE NashvillieHousing
   ADD OwnerSplitAddress Nvarchar(255);

   UPDATE NashvillieHousing
   SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

 ALTER TABLE NashvillieHousing
   ADD OwnerSplitCity Nvarchar(255);

   UPDATE NashvillieHousing
   SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

 ALTER TABLE NashvillieHousing
   ADD OwnerSplitState Nvarchar(255);

   UPDATE NashvillieHousing
   SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

 -- To see the 3 columns added at the end of the table
Select *
From PortifolioProject1.dbo.NashvillieHousing 


/* NOTES

In the PropertyAddress we have the address and then commas after and then 
comes the city, and there are no cammas anywhere else except before the 
City. And the commas act as a delimiter (Something that separates different 
columns or values.

 -- For PropertyAddress --
 . We use SUBSTRING (starting at position 1) and CHARINDEX
 . The CHARINDEX is used to search for a specific value (in this case comma)
   in a column (PropertyAddress) 
 . The results we get include the comma, to change that we can add -1 {CHARINDEX(',', PropertyAddress) -1)}
   This will remove the comma because " CHARINDEX(',', PropertyAddress)) " specify a position where the comma 
   is, therefore to remove comma from the results we can minus 1

. In the second SUBSTRING we do not  want to start at position 1, but we want to start where 
  the comma is ( the CHARINDEX poaition), but we want to put +1 because we want to get to the 
  beginning of this substring to not start with a comma
. Then we need to specify where the substring needs to finish so we use LEN(ProppertyAddress)
  because every row has different length of city name.

. We can't separate two values from one colunm without creating two other colunms, so we use ALTER TABLE
  and UPDATE to create two new columns (PropertySplitAddress and PropertySplitCity) and add those separated values in there. 
. And since the data type is a string we add Nvarchar(255) at the end, because we don't know how big the string will be.

 -- For OwnerAddress --
. In this column we have the address, city and the state. We need to split them out
. With this one we use PARSENAME instead of SUBSTRING because it is more useful when 
  dealing with stuff that are delimited by a specific value multiple times.
. PARSENAME (Easier than SUBSTRING) looks for period(.) and we have commas, so we use REPLACE to change the comma
  to period
. Something odd anout PARSENAME is that it does everything backwards, It starts separating 
  things backwards, starting with the state and finishing with the address. To change this we 
  start at 3, 2, 1 when we change the second parameter.
. Use ALTER TABLE and UPDATE to add these in the table (

*/


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortifolioProject1.dbo.NashvillieHousing 
Group by SoldAsVacant
Order by 2 ASC


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
From PortifolioProject1.dbo.NashvillieHousing 

UPDATE NashvillieHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END


/*
 NOTES
Distinct means different or non-repeating. It counts every category or value once, 
no matter how many times it actually appears in your dataset

. Since "Yes" and "No" are vastly more populated ones we should change the N and Y to
  them.
. To change them we can use CASE statement 
. Let's try to use UPDATE without ALTER TABLE as we tried in the 1st question to see if
  it will work [ it works]
. The UPDATE works (we run the first section to see the results)

*/

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates

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

From PortifolioProject1.dbo.NashvillieHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortifolioProject1.dbo.NashvillieHousing


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortifolioProject1.dbo.NashvillieHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




/* 
   NOTES
   It is not a standard practise to remove data that's in the database
   therefore it is not reccommended to remove duplicates, but you can do it 
   and make temporary table and put the removed duplicates in there

. We write a cte and do some windows functions to find where there are duplicate
  values.
. We want to partition our data, when we are removing duplicates we're gonna have duplicate 
  rows and we need to be able to have a way to identify those rows. That can be done by using 
  RANK, ORDER RANK or ROW NUMBER. And we are gonna use ROW NUMBER.Please look up the other ones
. Search PARTITION
. We need to partition the dataset on things that should be unique
. We ignore the UniqueID 
*/





