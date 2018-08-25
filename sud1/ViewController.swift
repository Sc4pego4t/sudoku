//
//  ViewController.swift
//  sud1
//
//  Created by Андрей Глухих on 21.02.2018.
//  Copyright © 2018 scapegoat. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 81
    }
    static var cellsArray:[[CollectionViewCell?]]=[[CollectionViewCell?]](repeating: [CollectionViewCell?](repeating: nil, count: 9), count: 9)

    var row=0,col=0

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.textField.accessibilityIdentifier=String(indexPath.row)
        ViewController.cellsArray[row][col]=cell
        col+=1
        if((indexPath.row+1)%9==0){
            row+=1
            col=0
           // print(row)
        }
        if(indexPath.row==80){
            paint()
            startGame()

        }
        return cell

    }

    static func paint(row:Int,col:Int){
        if(row >= 0 && row<3 || row >= 6 && row<9){
            if(col>=0 && col<3 || col>=6 && col<9){
                ViewController.cellsArray[row][col]?.textField.backgroundColor=UIColor.lightGray
            } else{
                ViewController.cellsArray[row][col]?.textField.backgroundColor=UIColor.white
            }
        }
        else{
            if(col>2 && col<6){
                ViewController.cellsArray[row][col]?.textField.backgroundColor=UIColor.lightGray
            } else{
                ViewController.cellsArray[row][col]?.textField.backgroundColor=UIColor.white
            }
        }
    }
    func paint(){
    for row in 0...8{
        for col in 0...8{
            ViewController.paint(row:row,col:col)
            }
        }
    }

    func startGame(){ //инициализация и генерация поля
        let newRowOffset=3 //смещение при переводе строки
        var i=1
        for mas in ViewController.cellsArray{
            for cell in mas{
                cell?.textField.text=String(i)
                i=offset(num: i)
            }
            i=offset(num: i,count:newRowOffset)
        }


        for _ in 0...100{
            var upper=UInt32(8),lower=UInt32(0)
            let num1=arc4random_uniform(upper - lower+1) + lower
            let temp=ViewController.areaScopes(num: num1)
            lower=temp.0;upper=temp.1
            let num2=arc4random_uniform(upper - lower+1) + lower
            if (num1==num2){
                continue
            }
            let numA1=Int((num1*10)%3)
            let numA2=Int((num2*10)%3)
            //перемешиваю
            swapRowInArea(numRow1: Int(num1), numRow2: Int(num2))
            swapColumnInArea(numColumn1: Int(num1), numColumn2: Int(num2))
            swapColumnArea(numColumn1: numA1, numColumn2: numA2)
            swapRowArea(numRow1: numA1, numRow2: numA2)
        }



        var erasedCells:Set<Int>=[]
        let upper=UInt32(8),lower=UInt32(0)
        for _ in 0...1{
            for i in 0...8{
                for _ in 0...2{
                    let randNum=Int(arc4random_uniform(upper - lower+1) + lower)
                        erasedCells.insert(i*9+randNum)
                    ViewController.cellsArray[i][randNum]?.textField.text=""
                }
            }
        }
        print(erasedCells)
        for row in 0...8{
            for col in 0...8{
                if !erasedCells.contains(row*9+col){
                    print(row*9+col)
                    ViewController.cellsArray[row][col]?.textField.isEnabled=false
                    ViewController.cellsArray[row][col]?.textField.textColor=UIColor.gray
                }
            }
        }

    }


    static func findError(index: Int){
        let legitNumbers:Set=[1,2,3,4,5,6,7,8,9]//символы которые могут быть в клетке
        //проверка ввода неверных символов
        let row=index/9, col=index%9
        let text=cellsArray[row][col]?.textField.text
        var num=Int(text ?? " ") ?? -1
        if !legitNumbers.contains(num){
            num = -1
        }
        if num == -1 && text != ""{
            cellsArray[row][col]?.textField.backgroundColor=UIColor.red
            return
        } else{
            paint(row:row,col:col)
        }
        //проверка блока в котором находится нажимаемая клетка
        
        print(areaScopes(num:UInt32(row)),areaScopes(num: UInt32(col)))
        let scopesRow=areaScopes(num:UInt32(row))
        let scopesCol=areaScopes(num: UInt32(col))
        var temp :Set<Int>=[]
        for r in scopesRow.0...scopesRow.1{
            for c in scopesCol.0...scopesCol.1{
                let num = convertToNum(cellsArray[Int(r)][Int(c)]?.textField.text)
                if num != -1 {
                    if(temp.contains(num)){
                        cellsArray[row][col]?.textField.backgroundColor=UIColor.yellow
                    } else{
                        temp.insert(num)
                    }
                }
            }
        }
        temp=[]
        //проверка строки в которой находится нажимаемая клетка
        for i in 0...8{
            let num = convertToNum(cellsArray[row][i]?.textField.text)
            if num != -1 {
                if(temp.contains(num)){
                    cellsArray[row][col]?.textField.backgroundColor=UIColor.yellow
                } else{
                    temp.insert(num)
                }
            }
        }
        temp=[]
        //проверка столбца в котором находится нажимаемая клетка
        for i in 0...8{
            let num = convertToNum(cellsArray[i][col]?.textField.text)
            if num != -1 {
                if(temp.contains(num)){
                    cellsArray[row][col]?.textField.backgroundColor=UIColor.yellow
                } else{
                    temp.insert(num)
                }
            }
        }
        var countNoEmptyCells=0
        for row in 0...8{
            for col in 0...8{
                if cellsArray[row][col]!.textField.text != ""{
                    if (cellsArray[row][col]?.textField.backgroundColor==UIColor.white || cellsArray[row][col]?.textField.backgroundColor==UIColor.lightGray){
                        //cellsArray[row][col]?.textField.backgroundColor=UIColor.green
                        countNoEmptyCells+=1

                    }
                }
            }
        }
        if countNoEmptyCells == 81{
            
        }
    }


    static func convertToNum(_ text:String?)->Int{
        return Int(text ?? " ") ?? -1
    }



    func offset(num:Int)->Int{
        if(num+1>9){
            return 1
        }
        else{
            return num+1
        }
    }
    func offset(num:Int,count:Int)->Int{
        var result=num
        if(num+count>9){
            for _ in 0...count{
                result=offset(num: result)
            }
            return result
        }
        else{
            return num+count
        }
    }
    static func areaScopes(num:UInt32)->(UInt32,UInt32){
        switch num {
        case 0...2:return(0,2)
        case 3...5:return(3,5)
        case 6...8:return(6,8)
        default:return(0,0)
        }
    }


    func swapRowInArea(numRow1:Int,numRow2:Int){
        for i in 0...8{
            let temp=ViewController.cellsArray[numRow1][i]?.textField.text
            ViewController.cellsArray[numRow1][i]?.textField.text=ViewController.cellsArray[numRow2][i]?.textField.text
            ViewController.cellsArray[numRow2][i]?.textField.text=temp
        }
    }
    func swapColumnInArea(numColumn1:Int,numColumn2:Int){
        for i in 0...8{
            let temp=ViewController.cellsArray[i][numColumn1]?.textField.text
            ViewController.cellsArray[i][numColumn1]?.textField.text=ViewController.cellsArray[i][numColumn2]?.textField.text
            ViewController.cellsArray[i][numColumn2]?.textField.text=temp
        }
    }
    func swapRowArea(numRow1:Int,numRow2:Int){
        for j in 0...2{
            swapRowInArea(numRow1: j+(numRow1*3), numRow2: j+(numRow2*3))
        }
    }
    func swapColumnArea(numColumn1:Int,numColumn2:Int){
        for j in 0...2{
            swapColumnInArea(numColumn1: j+(numColumn1*3), numColumn2: j+(numColumn2*3))
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 9
        let spaceBetweenCells: CGFloat = 0
        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
    }

}

