:- style_check(-discontiguous).  %allow discontiguous predicates
%General
%1stPredicate
convertBinToDec(Bin,Dec):- 
	numberBits(Bin,X),
	evaluate(Bin,X,0,Dec).

numberBits(0,0).
numberBits(Bin,N):-
	Bin \= 0,
	Bin1 is Bin//10,
	numberBits(Bin1,N1),
	N is N1+1.

evaluate(0,_,_,0).
evaluate(Bin,X,Pos,Dec):- 
	X > Pos,
	0 is Bin mod 2,
	Bin1 is Bin//10,
	Pos1 is Pos + 1,
	evaluate(Bin1,X,Pos1,Dec1),
	Dec is Dec1.
	
evaluate(Bin,X,Pos,Dec):- 
	X > Pos,
	1 is Bin mod 2,
	Bin1 is Bin//10,
	Pos1 is Pos + 1,
	evaluate(Bin1,X,Pos1,Dec1),
	Dec is Dec1 + (2^Pos).
			

%2ndPredicate
replaceIthItem(Item,List,I,Result):-
	length(List,N),
	I < N ,
	replaceIthItemHelper(Item,List,I,0,Result).

replaceIthItemHelper(Item,[_|T],I,I,[Item|T]).
replaceIthItemHelper(Item,[H|T],I,C,[H|T1]):-
				C < I,
				C1 is C + 1,
				replaceIthItemHelper(Item,T,I,C1,T1).
	
%3rdPredicate                  
splitEvery(_,[],[[]]).
splitEvery(N,List,[List]):-
	length(List,N).

splitEvery(N,List,R):-
	length(List,L),
	L > N,
	splitEveryH(N,List,0,[], R).

splitEveryH(_,[],_,TempList,[TempList]).
splitEveryH(N,[H|T],Current,Temp,R):-
	H \= null,
	Current < N,
	append(Temp,[H],T1),
	Current1 is Current + 1,
	splitEveryH(N,T,Current1,T1,R).
	
splitEveryH(N,[H|T],Current,List,R):-
	Current == N,
	R = [List|R1],
	splitEveryH(N,[H|T],0,[],R1).
	
%4thPredicate
logBase2(1,0).
logBase2(Num,Res):-
	Num > 1,
	Num1 is Num/2,
	logBase2(Num1,Res1),
	Res is Res1 + 1.

%5thPredicate
getNumBits(_,fullyAssoc,_,0).
getNumBits(N,setAssoc,_,BitsNum):-
	logBase2(N,BitsNum).

getNumBits(_,directMap,List,BitsNum):-
	length(List,L),
	logBase2(L,BitsNum).
			


%6thPredicate
fillZeros(N,0,N).
fillZeros(String,N,R):-
				N > 0,
               string_concat("0",String,S),
			   N1 is N - 1,
			   fillZeros(S,N1,R).

%DirectMap	
%getDataFromCache
	getDataFromCache(StringAddress,Cache,Data,0,directMap,BitsNum):-
		atom_number(StringAddress, Number),
		N is Number mod (10^BitsNum),
		convertBinToDec(N,Index),
		Tag is Number//(10^BitsNum),
		atom_number(NewTag, Tag),
		string_length(NewTag,L),
		F is 6 - BitsNum - L,
		fillZeros(NewTag,F,NewTag1),
		getDataFromCacheHD(Index,0,Cache,Data,NewTag1).
		
	getDataFromCacheHD(Index,Index,[item(tag(X),data(Data),1,_)|_],Data,X).
	getDataFromCacheHD(Index,Current,[_|T],Data,Tag):-
		Current < Index,
		Current1 is Current + 1,
		getDataFromCacheHD(Index,Current1,T,Data,Tag).
	
%SetAssoc
%getDataFromCache

getDataFromCache(StringAddress,Cache,Data,HopsNum,setAssoc,SetsNum):-
     atom_number(StringAddress,Number),
	 getNumBits(SetsNum,setAssoc,Cache,BitsNum),
	 Checkindex is (Number mod 10^(BitsNum)),
	 convertBinToDec(Checkindex,Index),
	 CheckTag is (Number//10^(BitsNum)),
	 atom_number(Tag,CheckTag),
	 string_length(Tag,L),
	 NeedtoFill is 6-BitsNum-L,
	 fillZeros(Tag,NeedtoFill,NewTag),
	 length(Cache,X),
	 NewSetsNum is X//SetsNum,
	 splitEvery(NewSetsNum,Cache,NewCache),
	 getCachetobeUsed(NewCache,Index,Used),
	 getDataFromCacheHelper(NewTag,Used,Data,HopsNum).

getCachetobeUsed([H|T],0,H).
getCachetobeUsed([H|T],X,L):-
     X>0,
     X1 is X-1,
     getCachetobeUsed(T,X1,L).
	 	 
getDataFromCacheHelper(X,[item(tag(X),data(Y),1,_)|_],Y,0).    
getDataFromCacheHelper(X,[item(tag(H),data(Y),_,_)|T],Unknown,HopsNum):-
     X\=H,
	 T\=[],
	 getDataFromCacheHelper(X,T,Unknown,NewHops),
	 HopsNum is NewHops+1.


%SetAssoc	 
%replaceInCache	

replaceInCache(Tag,Idx,Mem,OldCache,NewCache,ItemData,setAssoc,SetsNum):-
     length(OldCache,L),
	 NewSetsNum is L//SetsNum,
	 convertBinToDec(Idx,IdxDec),
	 splitEvery(NewSetsNum,OldCache,SplittedCache),
	 getCachetobeUsed(SplittedCache,IdxDec,CachetobeUsed),
	 %needtoconvertTagandIdxintostring
	 atom_number(StringTag,Tag),
	 string_length(StringTag,LengthOccupied),
	 logBase2(SetsNum,Numbits),
	 NeedtoFill is 6-Numbits-LengthOccupied,
	 fillZeros(StringTag,NeedtoFill,FullStringTag),
	 %needtogetdatafromMem
	 atom_number(StringTag,Tag),
	 atom_number(StringIdx,Idx),
	 string_concat(StringTag,StringIdx,SemiAddress),
	 atom_number(SemiAddress,Index),
	 convertBinToDec(Index,IndexforSearch),
	 getCachetobeUsed(Mem,IndexforSearch,ItemData),
	 %incrementorder
	 replaceInCacheSAH(ItemData,FullStringTag,CachetobeUsed,ReplaceinUsed),
	 replaceIthItem(ReplaceinUsed,SplittedCache,IdxDec,ListedNewCache),
	 appendN(ListedNewCache,NewCache).
	 
	 
	 
	 
	 
replaceInCacheSAH(ItemData,FullStringTag,CachetobeUsed,ReplaceinUsed):-
		checkInvalid(CachetobeUsed),
		incrementorder(CachetobeUsed,[],AdjustedOtrderSet),
		getIndexOfInvalid(CachetobeUsed,0,R),
		replaceIthItem(item(tag(FullStringTag),data(ItemData),1,0),AdjustedOtrderSet,R,ReplaceinUsed).
		
		
replaceInCacheSAH(ItemData,FullStringTag,CachetobeUsed,ReplaceinUsed):-
		\+checkInvalid(CachetobeUsed),
		incrementorder(CachetobeUsed,[],AdjustedOtrderSet),
		getHighestOrder(AdjustedOtrderSet,0,HighestOrder),
		getIndexOfHighestOrder(AdjustedOtrderSet,HighestOrder,0,IndexToBeReplaced),
		replaceIthItem(item(tag(FullStringTag),data(ItemData),1,0),AdjustedOtrderSet,IndexToBeReplaced,ReplaceinUsed).
	 
	 


getIndexOfInvalid([item(tag(_),data(_),0,_)|_],R,R).
getIndexOfInvalid([item(tag(_),data(_),1,_)|T],I,R):-
     Index is I+1,
	 getIndexOfInvalid(T,Index,R).

getIndexOfHighestOrder([item(tag(X),data(Y),1,Order)|T],Order,R,R).
getIndexOfHighestOrder([item(tag(X),data(Y),1,Order1)|T],Order,I,R):-
		Order1 \= Order,
     Index is I+1,
     getIndexOfHighestOrder(T,Order,Index,R).

incrementorder([item(tag(X),data(Y),0,Order)|[]],Acc,NewAcc):-
     append(Acc,[item(tag(X),data(Y),0,Order)],NewAcc).
incrementorder([item(tag(X),data(Y),1,Order)|[]],Acc,NewAcc):-
     OrderNew is Order+1,
     append(Acc,[item(tag(X),data(Y),1,OrderNew)],NewAcc).
incrementorder([item(tag(X),data(Y),1,Order)|T],Acc,R):-
	 NewOrder is Order+1,
     append([item(tag(X),data(Y),1,NewOrder)],Acc,NewAcc),
	 incrementorder(T,NewAcc,R).
incrementorder([item(tag(X),data(Y),0,Order)|T],Acc,R):-
     append([item(tag(X),data(Y),1,0)],Acc,NewAcc),
	 incrementorder(T,NewAcc,R).

getHighestOrder([],R,R).
getHighestOrder([item(tag(X),data(Y),0,Order)|T],CurrentHighest,R).
getHighestOrder([item(tag(X),data(Y),1,Order)|T],CurrentHighest,R):-
     Order>=CurrentHighest,
	 getHighestOrder(T,Order,R).
getHighestOrder([item(tag(X),data(Y),1,Order)|T],CurrentHighest,R):-
     Order<CurrentHighest,
	 getHighestOrder(T,CurrentHighest,R).
	 

	 

	 
	 
appendN([],[]).		
appendN([T],T).
appendN([H1|T],R):-
	T \= [],
	appendN(T,R1),
	append(H1,R1,R).
	




	 
%FullyAssoc
%getDataFromCache

getDataFromCache(StringAddress,Cache,Data,HopsNum,fullyAssoc,_):-
				getDataFromCacheFA(StringAddress,Cache,Data,HopsNum,0).
						
getDataFromCacheFA(StringAddress1,[item(tag(StringAddress2),data(Data),1,_)|_],Data,HopsNum,HopsNum):-
						atom_number(StringAddress1,N),
						atom_number(StringAddress2,N).
						
getDataFromCacheFA(StringAddress,[item(tag(Code),data(_),X,_)|T],Data,HopsNum,Acc):-
				atom_number(StringAddress,N1),
				atom_number(Code,N2),
				(N1 \= N2; N1 == N2, X is 0),
				Acc1 is Acc + 1,
			    getDataFromCacheFA(StringAddress,T,Data,HopsNum,Acc1).
		
%Direct Map
%2nd convertAddress
	convertAddress(Bin,BitsNum,Tag,Idx,directMap):-
		Idx is Bin mod (10^BitsNum),
		Tag is Bin//(10^BitsNum).
		
%SetAssoc		
%2nd convertAddress
	convertAddress(Bin,SetsNum,Tag,Idx,setAssoc):-
			logBase2(SetsNum,SizeOfIndex),
			Idx is Bin mod 10^SizeOfIndex,
			Tag is Bin // 10^SizeOfIndex.
			
%FullyAssoc
%2nd convertAddress
		convertAddress(Bin,_,Bin,_,fullyAssoc).
			
			
			
%DirectMap
%replaceInCache	

	replaceInCache(Tag,Idx,Mem,OldCache,NewCache,ItemData,directMap,BitsNum):-
		%Get Tag as String
			LT is 6 - BitsNum,
			atom_number(TagString,Tag),
			string_length(TagString,L1),
			LF is LT - L1,
			fillZeros(TagString,LF,NewTag),
			
		%Get the Pos in OldCache
			atom_number(IdxString,Idx),
			
		%Get Idx as String
			string_length(IdxString,L2),
			LI is BitsNum - L2,
			fillZeros(IdxString,LI,IdxString1),
			convertBinToDec(Idx,Pos),
		
		%Get the ItemData value	
			string_concat(TagString, IdxString1, Address),
			atom_number(Address,X),
			convertBinToDec(X,Pos1),
			getAddress(Pos1,Mem,0,ItemData),
			
		%Get Help
			helpRCD(NewTag,Pos,OldCache,NewCache,ItemData,0).
			
	helpRCD(Tag,Pos,[_|T],[item(tag(Tag),data(ItemData),1,0)|T],ItemData,Pos).
	helpRCD(Tag,Pos,[H|T],[H|T1],ItemData,Curr):-	
			Curr < Pos,
			Curr1 is Curr+1,
			helpRCD(Tag,Pos,T,T1,ItemData,Curr1).
			
%FullyAssoc
%3rd replaceInCache				
	replaceInCache(Tag,_,Mem,OldCache,NewCache,ItemData,fullyAssoc,_):-
		atom_number(TagString,Tag),
		string_length(TagString,L1),
		L is 6 - L1,
		fillZeros(TagString,L,NewTag),
		convertBinToDec(Tag,Pos),
		getAddress(Pos,Mem,0,ItemData),
		\+checkInvalid(OldCache),
		getMaxValid(OldCache,Max),
		rcfv(NewTag,OldCache,NewCache1,ItemData,Max),
		incValid(NewCache1,NewCache).
		
	replaceInCache(Tag,_,Mem,OldCache,NewCache,ItemData,fullyAssoc,_):-
		atom_number(TagString,Tag),
		string_length(TagString,L1),
		L is 6 - L1,
		fillZeros(TagString,L,NewTag),
		convertBinToDec(Tag,Pos),
		getAddress(Pos,Mem,0,ItemData),
		checkInvalid(OldCache),
		rcfi(NewTag,OldCache,NewCache1,ItemData),
		incValid(NewCache1,NewCache).
	
	getAddress(Curr,[H|_],Curr,H).
	getAddress(Pos,[_|T],Curr,ItemData):-
		Pos > Curr,
		Curr1 is Curr + 1,
		getAddress(Pos,T,Curr1,ItemData).
		
	rcfi(NewTag,[item(tag(_),data(_),0,_)|T],[item(tag(NewTag),data(ItemData),1,-1)|T],ItemData).
	rcfi(NewTag,[item(tag(Tag),data(Data),1,X)|T],[item(tag(Tag),data(Data),1,X)|T1],ItemData):-
			rcfi(NewTag,T,T1,ItemData).
			
	rcfv(NewTag,[item(tag(_),data(_),1,Max)|T],[item(tag(NewTag),data(ItemData),1,-1)|T],ItemData,Max).
	rcfv(NewTag,[item(tag(Tag),data(Data),1,X)|T],[item(tag(Tag),data(Data),1,X)|T1],ItemData,Max):-
					X \= Max,
					rcfv(NewTag,T,T1,ItemData,Max).
					
	checkInvalid([item(_,_,0,_)|_]).
	checkInvalid([item(_,_,1,_)|T]):-
			checkInvalid(T).
	
	getMaxValid([],0).
	getMaxValid([item(_,_,1,X)|T],Max):-
		getMaxValid(T,Max1),
		X > Max1,
		Max = X.
	
	getMaxValid([item(_,_,1,X)|T],Max):-
		getMaxValid(T,Max1),
		X =< Max1,
		Max = Max1.
		
	incValid([],[]).
	incValid([item(tag(Tag),data(ItemData),1,X)|T],[item(tag(Tag),data(ItemData),1,X1)|T1]):-
			X1 is X + 1,
			incValid(T,T1).
	incValid([item(tag(Tag),data(ItemData),0,X)|T],[item(tag(Tag),data(ItemData),0,X)|T1]):-
			incValid(T,T1).
			
	
%4thGetAddress	
	getData(StringAddress,OldCache,Mem,NewCache,Data,HopsNum,Type,BitsNum,hit):-
		getDataFromCache(StringAddress,OldCache,Data,HopsNum,Type,BitsNum),
		NewCache = OldCache.
		
	getData(StringAddress,OldCache,Mem,NewCache,Data,HopsNum,Type,BitsNum,miss):-
		\+getDataFromCache(StringAddress,OldCache,Data,HopsNum,Type,BitsNum),
		atom_number(StringAddress,Address),
		convertAddress(Address,BitsNum,Tag,Idx,Type),
		replaceInCache(Tag,Idx,Mem,OldCache,NewCache,Data,Type,BitsNum).

%5thRunProgram
	runProgram([],OldCache,_,OldCache,[],[],Type,_).
	runProgram([Address|AdressList],OldCache,Mem,FinalCache, [Data|OutputDataList],[Status|StatusList],Type,NumOfSets):-
				getNumBits(NumOfSets,Type,OldCache,BitsNum),
				(Type = setAssoc, Num = NumOfSets; Type \= setAssoc, Num = BitsNum),
				getData(Address,OldCache,Mem,NewCache,Data,HopsNum,Type,Num,Status),
				runProgram(AdressList,NewCache,Mem,FinalCache,OutputDataList,StatusList,Type,NumOfSets).
	
		
	
	
	
	
	
	
	
	
	
	

		
		
		
		


		
	








