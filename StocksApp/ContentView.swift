//
//  ContentView.swift
//  StocksAppCSCI571
//
//  Created by Aryan Pillai on 29/03/24.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import Kingfisher
import UIKit
import WebKit

struct Favorites:Codable {
    var ticker: String
    var name: String
    var c: Double
    var dp: Double
    var d: Double
}

struct Stocks:Codable {
    var ticker: String
    var name: String
    var quantity: Double
    var total: Double
    var change: Double
    var c: Double
}

struct Options:Codable{
    var ticker: String
    var name: String
}

struct Company:Codable {
    var ticker: String
    var name: String
    var exchange: String
    var ipo: String
    var finnhubIndustry: String
    var weburl: String
    var img: String
}

struct News:Codable {
    var headline: String
    var summary: String
    var source: String
    var url: String
    var image: String
    var datetime: Int
}

struct Lateststock:Codable {
    var c: Double
    var dp: Double
    var d: Double
    var h: Double
    var l: Double
    var o: Double
    var pc: Double
}

struct Peers:Codable {
    var array: [String]
}

struct Insider:Codable {
    var mt: Double
    var mp: Double
    var mn: Double
    var ct: Double
    var cp: Double
    var cn: Double
}

class ApiClient {
    private var host = "https://as3-express-blynbbpwha-wl.a.run.app/"
    
    func autocomplete(qstring: String, completion: @escaping (JSON?) -> Void){
        let parameters = ["searchq": qstring]
        AF.request(host+"/autocomplete", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let final = JSON(json["result"])
                var fav:[JSON] = []
                let group = DispatchGroup()
                for (_,subJson):(String, JSON) in final{
                    group.enter()
                    if subJson["type"].stringValue=="Common Stock" && !subJson["displaySymbol"].stringValue.contains("."){
                        fav.append(subJson)
                    }
                    group.leave()
                }
                group.notify(queue: .main) {
                    completion(JSON(fav))
                }
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getCompany(ticker: String, completion: @escaping (JSON?) -> Void){
        let parameters = ["ticker": ticker]
        AF.request(host+"/company", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getLatestStock(ticker: String, completion: @escaping (JSON?) -> Void){
        let parameters = ["ticker": ticker]
        AF.request(host+"/lateststock", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getNews(ticker: String, completion: @escaping (JSON?) -> Void){
        let parameters = ["ticker": ticker]
        AF.request(host+"/news", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                var final:[JSON] = []
                let group = DispatchGroup()
                var count = 0
                for (_,subJson):(String, JSON) in json{
                    group.enter()
                    if (!subJson["headline"].stringValue.isEmpty &&
                        !subJson["url"].stringValue.isEmpty &&
                        !subJson["image"].stringValue.isEmpty &&
                        !subJson["summary"].stringValue.isEmpty &&
                        !subJson["source"].stringValue.isEmpty) {
                        final.append(subJson)
                        count+=1
                        if count>20{
                            group.leave()
                            break
                        }
                    }
                    group.leave()
                }
                group.notify(queue: .main) {
                    completion(JSON(final))
                }
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getPeers(ticker: String, completion: @escaping (JSON?) -> Void){
        let parameters = ["ticker": ticker]
        AF.request(host+"/peers", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getInsider(ticker: String, completion: @escaping (JSON?) -> Void){
        let parameters = ["ticker": ticker]
        AF.request(host+"/insider", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                var tm = 0.0
                var tc = 0.0
                var pm = 0.0
                var pc = 0.0
                var nm = 0.0
                var nc = 0.0
                
                for (_,subJson):(String, JSON) in json["data"]{
                    
                    if subJson["mspr"].doubleValue<0{
                        nm+=subJson["mspr"].doubleValue
                    }
                    else{
                        pm+=subJson["mspr"].doubleValue
                    }
                    tm+=subJson["mspr"].doubleValue
                    if subJson["change"].doubleValue<0{
                        nc+=subJson["change"].doubleValue
                    }
                    else{
                        pc+=subJson["change"].doubleValue
                    }
                    tc+=subJson["change"].doubleValue
                }
                
                let final: [String: Double] = ["tm":tm,
                                               "tc":tc,
                                               "pm":pm,
                                               "pc":pc,
                                               "nm":nm,
                                               "nc":nc]
                completion(JSON(final))
                
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func storeFav(ticker: String,
                  name: String, completion: @escaping (JSON?) -> Void){
        
        let parameters = ["ticker": ticker,"name": name]
        AF.request(host+"/storeFav", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func deleteFav(ticker: String, completion: @escaping (JSON?) -> Void){
        let parameters = ["ticker": ticker]
        AF.request(host+"/deleteFav", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getFav(completion: @escaping (JSON?) -> Void){
        AF.request(host+"/getFav", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                var fav:[JSON] = []
                let group = DispatchGroup()
                for (_,subJson):(String, JSON) in json{
                    group.enter()
                    self.getLatestStock(ticker:subJson["ticker"].stringValue){
                        j in
                        let v = JSON(j ?? [])
                        do {
                            let final = try subJson.merged(with: v)
                            fav.append(final)
                            
                        } catch {
                            print("Error merging JSON: \(error)")
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    completion(JSON(fav))
                }
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func storeStock(ticker: String,
                    name: String,
                    quantity: Double,
                    total: Double,
                    completion: @escaping (JSON?) -> Void){
        let parameters = ["ticker": ticker,"name": name,"quantity": String(quantity),"total": String(total)]
        AF.request(host+"/storeStock", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func deleteStock(ticker: String, completion: @escaping (JSON?) -> Void){
        let parameters = ["ticker": ticker]
        AF.request(host+"/deleteStock", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func updateStock(ticker: String,
                     quantity: Double,
                     total: Double,
                     completion: @escaping (JSON?) -> Void){
        let parameters = ["ticker": ticker,"quantity": String(quantity),"total": String(total)]
        AF.request(host+"/updateStock", method: .get,parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
    
    func getStocks(completion: @escaping (JSON?) -> Void){
        AF.request(host+"/getStock", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                var fav:[JSON] = []
                let group = DispatchGroup()
                for (_,subJson):(String, JSON) in json{
                    group.enter()
                    self.getLatestStock(ticker:subJson["ticker"].stringValue){
                        j in
                        let v = JSON(j ?? [])
                        do {
                            var final = try subJson.merged(with: v)
                            if let totalString = final["total"].string,
                               let totalInt = Double(totalString) {
                                final["total"] = JSON(totalInt)
                            }
                            if let qString = final["quantity"].string,
                               let qInt = Double(qString) {
                                final["quantity"] = JSON(qInt)
                                print(final["quantity"])
                            }
                            final["change"] = JSON(final["c"].doubleValue - (final["total"].doubleValue/final["quantity"].doubleValue))
                            fav.append(final)
                            
                        } catch {
                            print("Error merging JSON: \(error)")
                        }
                        group.leave()
                    }
                }
                group.notify(queue: .main) {
                    completion(JSON(fav))
                }
            case .failure(let error):
                print(error)
                completion(nil)
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
//        HomeView()
        LaunchView()
    }
}

struct HomeView: View {
    @State private var ticker = ""
    @State private var t = ""
    @State private var money = 25000.0
    @State private var networth = 25000.0
    @State private var favorites: [Favorites]?
    @State private var stocks: [Stocks]?
    @State private var options: [Options]?
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    @State private var shouldNavigate = false
    let debounce = Debounce(timeInterval: 0.9, queue: .global(qos: .userInitiated))
    
    var body: some View {
        
        NavigationStack {
            VStack {
                if (shouldNavigate == false){
                    if let favorites = favorites {
                        
                        List {
                            Text(Date.now, formatter: {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MMMM d, yyyy"
                                return formatter
                            }())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.gray)
                            .padding(.vertical,4.0)
                            Section{
                                HStack {
                                    
                                    VStack(alignment: .leading) {
                                        Text("Net Worth")
                                            .font(.title3)
                                        Text("$"+String(format: "%.2f",networth))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                    
                                    Spacer()
                                    VStack(alignment: .leading) {
                                        Text("Cash Balance")
                                            .font(.title3)
                                        Text("$"+String(format: "%.2f",money))
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                }
                                if let stocks = stocks{
                                    ForEach(stocks, id: \.ticker) { fav in
                                        NavigationLink(destination: SearchView(ticker: fav.ticker, money: money)) {
                                            HStack{
                                                VStack(alignment: .leading) {
                                                    Text(fav.ticker)
                                                        .font(.title3)
                                                        .fontWeight(.bold)
//                                                    Text(fav.quantity)
//                                                        .foregroundColor(Color.gray)
                                                    
                                                }
                                                Spacer()
                                                VStack(alignment: .trailing){
                                                    Text("$"+String(format: "%.2f",fav.c*fav.quantity))
                                                        .fontWeight(.bold)
                                                    
                                                    
                                                    HStack{
                                                        if fav.change < 0 {
                                                            Image(systemName: "arrow.down.forward").foregroundColor(fav.change < 0 ? .red : .green)
                                                        } else {
                                                            Image(systemName: "arrow.up.forward").foregroundColor(fav.change < 0 ? .red : .green)
                                                        }
                                                        Text("$"+String(format: "%.2f",fav.change))
                                                            .foregroundColor(fav.change < 0 ? .red : .green)
                                                        Text("("+String(format: "%.2f", fav.change/fav.total)+"%)").foregroundColor(fav.change < 0 ? .red : .green)
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                    .onMove(perform: moveItem)
                                }
                                
                            }header: { Text("PORTFOLIO") }
                            Section{
                                ForEach(favorites, id: \.ticker) { fav in
                                    NavigationLink(destination: SearchView(ticker: fav.ticker, money: money)) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(fav.ticker)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                Text(fav.name)
                                                    .font(.body)
                                                    .foregroundColor(Color.gray)
                                                
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing){
                                                Text("$"+String(format: "%.2f",fav.c))
                                                    .fontWeight(.bold)
                                                HStack(alignment: .top){
                                                    if fav.d < 0 {
                                                        Image(systemName: "arrow.down.forward").foregroundColor(fav.d < 0 ? .red : .green)
                                                    } else {
                                                        Image(systemName: "arrow.up.forward").foregroundColor(fav.d < 0 ? .red : .green)
                                                    }
                                                    Text("$"+String(format: "%.2f",fav.d))
                                                        .foregroundColor(fav.d < 0 ? .red : .green)
                                                    Text("("+String(format: "%.2f", fav.dp)+"%)").foregroundColor(fav.d < 0 ? .red : .green)
                                                }.fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                    
                                }.onDelete(perform: deleteItem)
                                    .onMove(perform: moveItem)
                            }header: { Text("FAVORITES") }
                            Link(destination: URL(string: "https://finnhub.io/")!) {
                                Text("Powered by Finnhub.io")
                                    .font(.footnote)
                                    .foregroundColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.572))
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                    else{
                        ProgressView()
                        Text("Fetching Data...")
                            .foregroundColor(Color.gray)
                    }
                }
                else{
                    ResultsView(ticker: ticker, money: money,options: options)
                }
            }
            .navigationBarTitle("Stocks")
            .searchable(text: $ticker)
            .autocorrectionDisabled(true)
            .onChange(of: ticker){ old,new in
                debounce.dispatch {
                    self.options = []
                    shouldNavigate = !new.isEmpty
                    ApiClient().autocomplete(qstring: new){
                        json in
                        
                        if let jsonArray = json?.arrayObject as? [[String: Any]] {
                            
                            let array = jsonArray.map { dict in
                                Options(ticker: dict["symbol"] as? String ?? "",
                                        name: dict["description"] as? String ?? ""
                                )
                            }
                            shouldNavigate = !new.isEmpty
                            self.options = array
                        }
                    }
                }
            }
            .toolbar {
                EditButton()
            }
            .onAppear{
                self.money = 25000.0
                self.networth = 25000.0
                ApiClient().getFav{
                    json in
                    if let jsonArray = json?.arrayObject as? [[String: Any]] {
                        let favoritesArray = jsonArray.map { dict in
                            Favorites(ticker: dict["ticker"] as? String ?? "",
                                      name: dict["name"] as? String ?? "",
                                      c: dict["c"] as? Double ?? 0,
                                      dp: dict["dp"] as? Double ?? 0,
                                      d: dict["d"] as? Double ?? 0
                            )
                        }
                        self.favorites = favoritesArray
                    }
                }
                
                ApiClient().getStocks{
                    json in
                    
                    if let jsonArray = json?.arrayObject as? [[String: Any]] {
                        let array = jsonArray.map { dict in
                            
                            Stocks(ticker: dict["ticker"] as? String ?? "",
                                   name: dict["name"] as? String ?? "",
                                   quantity: dict["quantity"] as? Double ?? 0,
                                   total: dict["total"] as? Double ?? 0,
                                   change: dict["change"] as? Double ?? 0,
                                   c: dict["c"] as? Double ?? 0
                                   
                            )
                        }
                        var tcost = 0.0
                        for item in array{
                            self.money-=item.total
                            tcost+=item.quantity*item.c
                        }
                        self.networth=self.money+tcost
                        self.stocks = array
                    }
                }
                
            }
            .onReceive(timer) { _ in
                ApiClient().getStocks{
                    json in
                    
                    if let jsonArray = json?.arrayObject as? [[String: Any]] {
                        let array = jsonArray.map { dict in
                            
                            Stocks(ticker: dict["ticker"] as? String ?? "",
                                   name: dict["name"] as? String ?? "",
                                   quantity: dict["quantity"] as? Double ?? 0,
                                   total: dict["total"] as? Double ?? 0,
                                   change: dict["change"] as? Double ?? 0,
                                   c: dict["c"] as? Double ?? 0
                                   
                            )
                        }
                        var tcost = 0.0
                        for item in array{
                            tcost+=item.quantity*item.c
                        }
                        self.networth=self.money+tcost
                        self.stocks = array
                    }
                }
            }
        }
    }
    func deleteItem(at offsets: IndexSet) {
        for o in offsets{
            if let favorite = self.favorites?[o] {
                ApiClient().deleteFav(ticker: favorite.ticker) { json in
                    ApiClient().getFav{
                        json in
                        if let jsonArray = json?.arrayObject as? [[String: Any]] {
                            let favoritesArray = jsonArray.map { dict in
                                Favorites(ticker: dict["ticker"] as? String ?? "",
                                          name: dict["name"] as? String ?? "",
                                          c: dict["c"] as? Double ?? 0,
                                          dp: dict["dp"] as? Double ?? 0,
                                          d: dict["d"] as? Double ?? 0
                                )
                            }
                            self.favorites = favoritesArray
                        }
                    }
                }
            }
        }
    }
    
    func moveItem(from source: IndexSet, to destination: Int) {
        
    }
    
    final class Debounce {
        
        private let timeInterval: TimeInterval
        private let queue: DispatchQueue
        private var dispatchWorkItem = DispatchWorkItem(block: {})
        
        init(timeInterval: TimeInterval, queue: DispatchQueue) {
            self.timeInterval = timeInterval
            self.queue = queue
        }
        
        func dispatch(_ block: @escaping () -> Void) {
            dispatchWorkItem.cancel()
            let workItem = DispatchWorkItem {
                block()
            }
            dispatchWorkItem = workItem
            queue.asyncAfter(deadline: .now() + timeInterval, execute: dispatchWorkItem)
        }
    }
}

struct LaunchView: View {
    @State private var isActive = false
    
    var body: some View {
        VStack {
            Image("logoImage")
                .frame(width: 100, height: 100)
            
            
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                self.isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive, content: {
            HomeView()
        })
        .transaction({ transaction in
            // disable the default FullScreenCover animation
            transaction.disablesAnimations = true
            
            // add custom animation for presenting and dismissing the FullScreenCover
            transaction.animation = .linear(duration: 1)
        })
    }
}

struct HTMLView: UIViewRepresentable {
    let fileName: String
    let data: String
    let color: String?
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let filePath = Bundle.main.url(forResource: fileName, withExtension: "html") else {
            return
        }
        
        var urlComponents = URLComponents(url: filePath, resolvingAgainstBaseURL: false)
        if let color = color {
            urlComponents?.queryItems = [URLQueryItem(name: "ticker", value: data),
                                         URLQueryItem(name: "color", value: color)]
        } else {
            urlComponents?.queryItems = [URLQueryItem(name: "ticker", value: data)]
        }
        
        guard let url = urlComponents?.url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct ResultsView: View{
    let ticker: String
    let money:Double
    let options: [Options]?
    
    var body: some View {
        VStack{
            List{
                if let options = options{
                    ForEach(options, id: \.ticker){o in
                        NavigationLink(destination: SearchView(ticker: o.ticker, money: money)) {
                            
                            VStack(alignment: .leading){
                                Text(o.ticker)
                                
                                    .fontWeight(.bold)
                                Text(o.name)
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct SearchView: View {
    
    
    
    let ticker: String
    @State var money: Double
    @State private var company: Company?
    @State private var lateststock: Lateststock?
    @State private var insider: Insider?
    @State private var peers:[String] = []
    @State private var news: [News]?
    @State private var stock: Stocks?
    @State private var isSheetPresented: [Int: Bool] = [:]
    @State private var isStockSheet: Bool = false
    @State private var isStockSubmit: Bool = false
    @State private var isStockBought: Bool = false
    @State private var quantity:Double = 0
    let formatter = RelativeDateTimeFormatter()
    
    
    
    @State private var favFlag:Bool = false
    @State private var showToast: Bool = false
    @State private var toastText: String = ""
    @State private var showHomeView = false
    
    private func relativeTimeString(for date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date, to: Date())
        
        if let hours = components.hour, let minutes = components.minute {
            if hours > 0 {
                if minutes > 0 {
                    return "\(hours) hr, \(minutes) mins"
                } else {
                    return "\(hours) hr"
                }
            } else {
                return "\(minutes) mins"
            }
        } else {
            return "Just now"
        }
    }
    
    var body: some View {
        
        ZStack {
            VStack{
                if let company = company, let lateststock = lateststock,
                   let insider = insider, let news = news{
                    ScrollView{
                        VStack(alignment: .leading){
    //                        HStack(content: {
    //                            Spacer()
    //                            KFImage(URL(string: company.img)!)
    //                                .resizable()
    //                                .aspectRatio(contentMode: .fill)
    //                                .clipShape(RoundedRectangle(cornerRadius: 5))
    //                                .frame(width: 35.0, height: 35.0)
    //                        })
                            HStack{
                                Text(company.name)
                                    .font(.body)
                                    .foregroundColor(Color.gray)
                                Spacer()
                                KFImage(URL(string: company.img)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .frame(width: 40,
                                           height: 40
                                            )
                            }
                            HStack{
                                Text("$"+String(format: "%.2f",lateststock.c))
                                    .font(.title)
                                    .fontWeight(.semibold)
                                if lateststock.d < 0 {
                                    Image(systemName: "arrow.down.forward").foregroundColor(lateststock.d < 0 ? .red : .green)
                                } else {
                                    Image(systemName: "arrow.up.forward").foregroundColor(lateststock.d < 0 ? .red : .green)
                                }
                                Text("$"+String(format: "%.2f",lateststock.d))
                                    .foregroundColor(lateststock.d < 0 ? .red : .green)
                                Text("("+String(format: "%.2f", lateststock.dp)+"%)").foregroundColor(lateststock.d < 0 ? .red : .green)
                            }
                            
                            TabView{
                                HTMLView(fileName: "hourlyChart", data: company.ticker, color: lateststock.d < 0 ? "red" : "green")
                                
                                    .tabItem {
                                        Label("Hourly", systemImage: "chart.xyaxis.line")
                                    }
                                
                                HTMLView(fileName: "historyChart", data: company.ticker, color: nil)
                                
                                    .tabItem {
                                        Label("Historical", systemImage: "clock.fill")
                                    }
                            }.frame(height: 450)
                            
                            VStack(alignment: .leading){
                                Text("Portfolio")
                                    .font(.title2)
                            }
                            HStack{
                                if let stock = stock{
                                    VStack(alignment: .leading){
                                        HStack{
                                            Text("Shares Owned:")
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                            Text(String(stock.quantity))
                                                .font(.footnote)
                                        }
                                        HStack{
                                            Text("Avg. Cost / Share:")
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                            Text(String(format: "%.2f",stock.total/stock.quantity))
                                                .font(.footnote)
                                        }
                                        HStack{
                                            Text("Change:")
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                            Text("$"+String(format: "%.2f",stock.change))
                                                .font(.footnote)
                                                .foregroundColor(stock.change < 0 ? .red : .green)
                                        }
                                        HStack{
                                            Text("Market Value:")
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                            Text("$"+String(format: "%.2f",lateststock.c * stock.quantity))
                                                .font(.footnote)
                                                .foregroundColor(lateststock.c * stock.quantity < stock.total ? .red : .green)
                                        }
                                        
                                    }
                                }
                                else{
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text("You have 0 shares of "+company.ticker+".")
                                                .font(.footnote)
                                            Text("Start Trading!")
                                                .font(.footnote)
                                        }
                                    }
                                }
                                Spacer().frame(width:30)
                                Button("Trade") {
                                    isStockSheet.toggle()
                                }.padding(.horizontal, 50.0)
                                    .padding(.vertical, 15.0)
                                    .background(Color.green)
                                    .foregroundColor(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .sheet(isPresented: $isStockSheet)
                                {
                                    if isStockSubmit == false{
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    isStockSheet = false
                                                }, label: {
                                                    Image(systemName: "xmark")
                                                        .foregroundColor(.black)
                                                        .font(.headline)
                                                })
                                                .padding()
                                            }
                                            HStack{
                                                Spacer()
                                                Text("Trade "+company.name+" shares")
                                                    .fontWeight(.bold)
                                                Spacer()
                                            }
                                            Spacer().frame(height: 250)
                                            HStack{
                                                TextField("0",value: $quantity, formatter: NumberFormatter())
                                                    .font(.system(size: 100))
                                                    .keyboardType(.numberPad)
                                                
                                                VStack(alignment: .trailing){
                                                    if quantity>1{
                                                        Text("Shares")
                                                            .font(.largeTitle)
                                                    }
                                                    else{
                                                        Text("Share")
                                                            .font(.largeTitle)
                                                    }
                                                    
                                                }
                                            }
                                            HStack{
                                                Spacer()
                                                VStack(alignment: .trailing){
                                                    Text("x $"+String(format: "%.2f",lateststock.c)+"/share = $"+String(format: "%.2f",lateststock.c * quantity))
                                                }
                                            }
                                            Spacer().frame(height: 200)
                                            HStack{
                                                Spacer()
                                                Text("$"+String(format: "%.2f",money)+" available to buy "+company.ticker)
                                                    .font(.caption)
                                                    .foregroundColor(Color.gray)
                                                Spacer()
                                            }
                                            HStack{
                                                
                                                Button("Buy") {
                                                    if(quantity*lateststock.c>money){
                                                        toastText = "Not enough money to buy"
                                                        showToast.toggle()
                                                    }
                                                    else if(quantity<=0){
                                                        toastText = "Please enter a valid amount."
                                                        showToast.toggle()
                                                    }
                                                    else if let stock = stock{
                                                        ApiClient().updateStock(ticker: company.ticker, quantity: stock.quantity+quantity, total: stock.total + (lateststock.c*quantity)){
                                                            json in
                                                            money=money-(lateststock.c*quantity)
                                                            isStockBought.toggle()
                                                            isStockSubmit.toggle()
                                                        }
                                                    }
                                                    else{
                                                        
                                                        ApiClient().storeStock(ticker: company.ticker,
                                                                               name:company.name,quantity: quantity, total: (lateststock.c*quantity)){
                                                            json in
                                                            money=money-(lateststock.c*quantity)
                                                            isStockBought.toggle()
                                                            isStockSubmit.toggle()
                                                        }
                                                    }
                                                }.padding(.horizontal, 70.0)
                                                    .padding(.vertical, 15.0)
                                                    .background(Color.green)
                                                    .foregroundColor(Color.white)
                                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                                Spacer()
                                                Button("Sell") {
                                                    if(quantity<=0){
                                                        toastText = "Please enter a valid amount."
                                                        showToast.toggle()
                                                    }
                                                    else if let stock = stock{
                                                        if quantity>stock.quantity{
                                                            toastText = "Not enough shares to sell"
                                                            showToast.toggle()
                                                        }
                                                        else if quantity == stock.quantity{
                                                            ApiClient().deleteStock(ticker: company.ticker){json in
                                                                money=money+(lateststock.c*quantity)
                                                                isStockSubmit.toggle()
                                                            }
                                                        }
                                                        else{
                                                            ApiClient().updateStock(ticker: company.ticker, quantity: stock.quantity-quantity, total: stock.total - (lateststock.c*quantity)){
                                                                json in
                                                                money=money+(lateststock.c*quantity)
                                                                isStockSubmit.toggle()
                                                            }
                                                        }
                                                    }
                                                }.padding(.horizontal, 70.0)
                                                    .padding(.vertical, 15.0)
                                                    .background(Color.green)
                                                    .foregroundColor(Color.white)
                                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                            }
                                            
                                            
                                            Spacer().frame(height: 10)
                                        }.toast(isPresented: self.$showToast) {
                                            HStack {
                                                Text(toastText)
                                                    .foregroundColor(Color.white)
                                                
                                            } //HStack
                                        } //toast
                                        .padding(.horizontal, 20.0)
                                    }
                                    else{
                                        
                                        VStack{
                                            Spacer()
                                            Text("Congratulations!")
                                                .font(.largeTitle)
                                                .foregroundColor(Color.white)
                                            if isStockBought == true{
                                                
                                                let intQuantity = Int(quantity)
                                                if intQuantity>1{
                                                    Text("You have successfully bought \(intQuantity) shares of \(company.ticker)")
                                                        .foregroundColor(Color.white)
                                                }
                                                else{
                                                    Text("You have successfully bought \(intQuantity) share of \(company.ticker)")
                                                        .foregroundColor(Color.white)
                                                }
                                                
                                            }
                                            else{
                                                let intQuantity = Int(quantity)
                                                if intQuantity>1{
                                                    Text("You have successfully sold \(intQuantity) shares of \(company.ticker)")
                                                        .foregroundColor(Color.white)
                                                }
                                                else{
                                                    Text("You have successfully sold \(intQuantity) share of \(company.ticker)")
                                                        .foregroundColor(Color.white)
                                                }
                                            }
                                            
                                            Spacer()
                                            Button("Done") {
                                                
                                                stock = nil
                                                ApiClient().getStocks{
                                                    json in
                                                    
                                                    if let jsonArray = json?.arrayObject as? [[String: Any]] {
                                                        for item in jsonArray{
                                                            let t = item["ticker"] as? String ?? ""
                                                            if t == ticker{
                                                                self.stock = Stocks(ticker: item["ticker"] as? String ?? "",
                                                                                    name: item["name"] as? String ?? "",
                                                                                    quantity: item["quantity"] as? Double ?? 0,
                                                                                    total: item["total"] as? Double ?? 0,
                                                                                    change: item["change"] as? Double ?? 0,
                                                                                    c: item["c"] as? Double ?? 0)
                                                            }
                                                        }
                                                    }
                                                    isStockSubmit = false
                                                    isStockSheet = false
                                                    isStockBought = false
                                                }
                                                
                                            }
                                            .padding(.horizontal, 150.0)
                                            .padding(.vertical, 20.0)
                                            .background(Color.white)
                                            .foregroundColor(Color.green)
                                            .clipShape(RoundedRectangle(cornerRadius: 30))
                                            
                                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .background(Color.green)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading){
                                Text("Stats")
                                    .font(.title2)
                                Spacer().frame(height: 20)
                                HStack{
                                    VStack(alignment: .leading){
                                        HStack {
                                            Text("High Price: ")
                                                .font(.footnote)
                                            .fontWeight(.bold)
                                            Text("$"+String(lateststock.h))
                                                .font(.footnote)
                                        }
                                        Spacer().frame(height: 10)
                                        
                                        HStack{
                                            Text("Low Price: ")
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                            Text("$"+String(lateststock.l))
                                                .font(.footnote)
                                        }
                                    }
                                    Spacer().frame(width: 32)
                                    VStack(alignment: .leading){
                                        HStack {
                                            Text("Open Price: ")
                                                .font(.footnote)
                                            .fontWeight(.bold)
                                            Text("$"+String(lateststock.o))
                                                .font(.footnote)
                                        }
                                        
                                        Spacer().frame(height: 10)
                                        HStack {
                                            Text("Prev. Close: ")
                                                .font(.footnote)
                                            .fontWeight(.bold)
                                            
                                            Text("$"+String(lateststock.pc))
                                                .font(.footnote)
                                        }
                                        
                                    }
                                }
    //
    //                                    .font(.footnote)
    //                                Spacer().frame(width:40
                                
                                
                                
                                
                                
    //                                    .font(.footnote)
    //
    //                            }
                            }
                            Spacer().frame(height: 20)
                            VStack{
                                Text("About")
                                    .font(.title2)
                            }
                            Spacer().frame(height: 10)
                            HStack(){
                                
                                VStack(alignment: .leading){
                                    Text("IPO Start Date: ")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                    Text("Industry: ")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                    Text("Webpage: ")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                    Text("Company Peers: ")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                }
                                Spacer().frame(width: 60)
                                VStack(alignment: .leading){
                                    Text(company.ipo)
                                        .font(.footnote)
                                    Text(company.finnhubIndustry)
                                        .font(.footnote)
                                    Link(destination: URL(string: company.weburl)!) {
                                        Text(company.weburl)
                                            .font(.footnote)
                                        
                                    }
                                    ScrollView(.horizontal) {
                                        LazyHStack() {
                                            ForEach(peers, id: \.self) { item in
                                                NavigationLink(destination: SearchView(ticker: item, money: money)) {
                                                    Text(item)
                                                        .font(.footnote)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Spacer().frame(height: 20)
                            VStack{
                                Text("Insights")
                                    .font(.title2)
                            }
                            Spacer().frame(height: 10)
                            HStack{
                                Spacer()
                                Text("Insider Sentiments")
                                    .font(.title3)
                                Spacer()
                            }
                            Spacer().frame(height: 16)
                            VStack{
                                HStack{
                                    Text(company.name)
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                    Text("MSPR")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                    Text("Change")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                }
                                Divider()
                                HStack{
                                    Text("Total")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                    Text(String(format: "%.2f",insider.mt))
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                    Text(String(format: "%.2f",insider.ct))
                                        .frame(maxWidth: .infinity)
                                }
                                Divider()
                                HStack{
                                    Text("Positive")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                    Text(String(format: "%.2f",insider.mp))
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                    Text(String(format: "%.2f",insider.cp))
                                        .frame(maxWidth: .infinity)
                                }
                                Divider()
                                HStack{
                                    Text("Negative")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                    Text(String(format: "%.2f",insider.mn))
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                    Text(String(format: "%.2f",insider.cn))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            HTMLView(fileName: "recommendationChart", data: company.ticker, color: nil).frame(height: 350)
                            Spacer().frame(height: 20)
                            HTMLView(fileName: "surpriseChart", data: company.ticker, color: nil).frame(height: 350)
                            Spacer().frame(height: 20)
                            VStack{
                                Text("News")
                                    .font(.title2)
                            }
                            ForEach(Array(news.enumerated()), id: \.offset) { index, item in
                                if index == 0 {
                                    Spacer().frame(height: 20)
                                    let date = Date(timeIntervalSince1970: TimeInterval(item.datetime))
                                    let relativeDate = formatter.localizedString(for: date, relativeTo: Date.now)
                                    VStack(alignment: .leading){
                                        KFImage(URL(string: item.image)!).resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                        
                                        Text(item.source+"  "+relativeTimeString(for: date))
                                            .font(.caption)
                                            .foregroundColor(Color.gray)
                                        Text(item.headline)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                    }.onTapGesture {
                                        isSheetPresented[index] = true
                                    }
                                    .sheet(isPresented: Binding(
                                        get: { isSheetPresented[index] ?? false },
                                        set: { isSheetPresented[index] = $0 }
                                    )) {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    isSheetPresented[index] = false
                                                }, label: {
                                                    Image(systemName: "xmark")
                                                        .foregroundColor(.black)
                                                        .font(.headline)
                                                })
                                                .padding()
                                            }
                                            VStack(alignment: .leading){
                                                Text(item.source)
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                
                                                Text(date, formatter: {
                                                    let formatter = DateFormatter()
                                                    formatter.dateFormat = "MMMM d, yyyy"
                                                    return formatter
                                                }())
                                                .font(.caption)
                                                .foregroundColor(Color.gray)
                                            }
                                            Divider()
                                            VStack(alignment: .leading){
                                                Text(item.headline)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                Text(item.summary)
                                                    .font(.footnote)
                                                HStack{
                                                    Text("For more details click")
                                                        .font(.caption)
                                                        .foregroundColor(Color.gray)
                                                    Link(destination: URL(string: item.url)!) {
                                                        Text("here")
                                                            .font(.caption)
                                                        
                                                    }
                                                }
                                            }
                                            HStack{
                                                Image(systemName: "xmark")
                                                    .renderingMode(.original)
                                                    .resizable()
                                                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                                                    .frame(width: 40, height: 40)
    //                                            KFImage(URL(string: "https://static.vecteezy.com/system/resources/previews/018/930/476/non_2x/facebook-logo-facebook-icon-transparent-free-png.png")!).resizable()
    //                                                .aspectRatio(contentMode: .fill)
    //                                                .clipShape(RoundedRectangle(cornerRadius: 15))
    //                                            Image("https://static.vecteezy.com/system/resources/previews/018/930/476/non_2x/facebook-logo-facebook-icon-transparent-free-png.png")
    //                                                .resizable()
    //                                                .aspectRatio(contentMode: .fit)
    //                                                .frame(width: 50, height: 50)
                                                Link(destination: URL(string: "https://twitter.com/intent/tweet?text="+item.url)!) {
    //                                                Image("facebook")
    //                                                    .renderingMode(.original)
    //                                                    .resizable()
    //                                                    .aspectRatio(contentMode: .fit)
    //                                                    .cornerRadius(10)
    //                                                    .padding()
                                                    Image("twitter").renderingMode(.original)  // << here !!
                                        .resizable()
                                                }
                                                
//                                                Image(systemName: "xmark")
                                                Link(destination: URL(string: "https://www.facebook.com/sharer/sharer.php?u="+item.url+"&amp;src=sdkpreparse")!) {
                                                    Image(uiImage: UIImage(named: "facebook")!)
                                                        
                                                }
                                                
                                            }.frame(width: 100)
                                            Spacer()
                                            
                                        }
                                        .padding(.horizontal, 20.0)
                                    }
                                    Divider()
                                } else {
                                    let date = Date(timeIntervalSince1970: TimeInterval(item.datetime))
                                    let relativeDate = formatter.localizedString(for: date, relativeTo: Date.now)
                                    HStack{
                                        VStack(alignment: .leading){
                                            HStack{
                                                Text(item.source+"  "+relativeTimeString(for: date))
                                                    .font(.caption)
                                                    .foregroundColor(Color.gray)
                                            }
                                            Text(item.headline)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                        }
                                        Spacer()
                                        VStack(alignment: .trailing){
                                            KFImage(URL(string: item.image)!).resizable()
    //                                            .aspectRatio(contentMode: .fit)
                                                .frame(width:80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                
                                        }
                                        
                                    }.onTapGesture { // Wrap VStack with Button
                                        isSheetPresented[index] = true
                                    }
                                    .sheet(isPresented: Binding(
                                        get: { isSheetPresented[index] ?? false },
                                        set: { isSheetPresented[index] = $0 }
                                    )) {
                                        VStack(alignment: .leading) {
                                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    isSheetPresented[index] = false
                                                }, label: {
                                                    Image(systemName: "xmark")
                                                        .foregroundColor(.black)
                                                        .font(.headline)
                                                })
                                                .padding()
                                            }
                                            VStack(alignment: .leading){
                                                Text(item.source)
                                                    .font(.title)
                                                    .fontWeight(.bold)
                                                Text(date, formatter: {
                                                    let formatter = DateFormatter()
                                                    formatter.dateFormat = "MMMM d, yyyy"
                                                    return formatter
                                                }())
                                                .font(.caption)
                                                .foregroundColor(Color.gray)
                                            }
                                            Divider()
                                            VStack(alignment: .leading){
                                                Text(item.headline)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                Text(item.summary)
                                                    .font(.footnote)
                                                HStack{
                                                    Text("For more details click")
                                                        .font(.caption)
                                                        .foregroundColor(Color.gray)
                                                    Link(destination: URL(string: item.url)!) {
                                                        Text("here")
                                                            .font(.caption)
                                                        
                                                    }
                                                }
                                            }
                                            HStack{
                                                Link(destination: URL(string: "https://twitter.com/intent/tweet?text="+item.url+"%20"+"item.url")!) {
                                                    Image("twitter")
                                                        .resizable()
                                                        .scaledToFit()
                                                }
                                                Link(destination: URL(string: "https://www.facebook.com/sharer/sharer.php?u="+item.url+"&amp;src=sdkpreparse")!) {
                                                    Image("facebook")
                                                        .resizable()
                                                        .scaledToFit()
                                                }
                                                
                                            }
                                            .frame(width: 100)
                                            Spacer()
                                            
                                        }
                                        .padding(.horizontal, 20.0)
                                    }
                                    Spacer().frame(height: 20)
                                }
                            }
                            NavigationLink(destination: HomeView(), isActive: $showHomeView) {
                                EmptyView()
                            }
                        }
                    }
                    .navigationTitle(company.ticker)
                    .navigationBarItems(trailing:
                                            Button(action: {
                        if favFlag{
                            ApiClient().deleteFav(ticker: company.ticker){
                                json in
                                favFlag.toggle()
                            }
                        }
                        else{
                            ApiClient().storeFav(ticker: company.ticker, name: company.name){
                                json in
                                favFlag.toggle()
                                showToast.toggle()
                            }
                        }
                        
                    }) {
                        Image(systemName: favFlag ? "plus.circle.fill" : "plus.circle")
                            .foregroundColor(Color.blue)
                    }
                    )
                    .toast(isPresented: self.$showToast) {
                        HStack {
                            Text("Adding "+company.ticker+" to Favorites")
                                .foregroundColor(Color.white)
                            
                        } //HStack
                    } //toast
                    .padding(.horizontal, 20.0)
                }
                else{
                    ProgressView()
                    Text("Fetching Data...")
                        .foregroundColor(Color.gray)
                }
            }.onAppear{
                ApiClient().getCompany(ticker: ticker){
                    json in
                    if let dict = json?.dictionaryObject {
                        let result = Company(
                            ticker: dict["ticker"] as? String ?? "",
                            name: dict["name"] as? String ?? "",
                            exchange: dict["exchange"] as? String ?? "",
                            ipo: dict["ipo"] as? String ?? "",
                            finnhubIndustry: dict["finnhubIndustry"] as? String ?? "",
                            weburl: dict["weburl"] as? String ?? "",
                            img: dict["logo"] as? String ?? ""
                        )
                        self.company = result
                    }
                }
                
                ApiClient().getPeers(ticker: ticker){
                    json in
                    
                    if let array = json?.arrayObject {
                        let stringArray = array.compactMap { $0 as? String }
                        self.peers = stringArray
                    }
                    
                }
                
                ApiClient().getLatestStock(ticker: ticker){
                    json in
                    if let dict = json?.dictionaryObject {
                        let result = Lateststock(
                            c: dict["c"] as? Double ?? 0,
                            dp: dict["dp"] as? Double ?? 0,
                            d: dict["d"] as? Double ?? 0,
                            h: dict["h"] as? Double ?? 0,
                            l: dict["l"] as? Double ?? 0,
                            o: dict["o"] as? Double ?? 0,
                            pc: dict["pc"] as? Double ?? 0
                        )
                        self.lateststock = result
                    }
                }
                
                ApiClient().getInsider(ticker: ticker){
                    json in
                    if let dict = json?.dictionaryObject {
                        let result = Insider(
                            mt: dict["tm"] as? Double ?? 0,
                            mp: dict["pm"] as? Double ?? 0,
                            mn: dict["nm"] as? Double ?? 0,
                            ct: dict["tc"] as? Double ?? 0,
                            cp: dict["pc"] as? Double ?? 0,
                            cn: dict["nc"] as? Double ?? 0
                        )
                        self.insider = result
                    }
                }
                
                ApiClient().getNews(ticker: ticker){
                    json in
                    
                    if let jsonArray = json?.arrayObject as? [[String: Any]] {
                        let array = jsonArray.map { dict in
                            
                            News(headline: dict["headline"] as? String ?? "",
                                 summary: dict["summary"] as? String ?? "",
                                 source: dict["source"] as? String ?? "",
                                 url: dict["url"] as? String ?? "",
                                 image: dict["image"] as? String ?? "",
                                 datetime: dict["datetime"] as? Int ?? 0
                            )
                        }
                        
                        self.news = array
                    }
                }
                
                ApiClient().getFav{
                    json in
                    if let jsonArray = json?.arrayObject as? [[String: Any]] {
                        for item in jsonArray{
                            let t = item["ticker"] as? String ?? ""
                            if t == ticker{
                                favFlag = true
                            }
                        }
                    }
                }
                ApiClient().getStocks{
                    json in
                    if let jsonArray = json?.arrayObject as? [[String: Any]] {
                        for item in jsonArray{
                            let t = item["ticker"] as? String ?? ""
                            if t == ticker{
                                self.stock = Stocks(ticker: item["ticker"] as? String ?? "",
                                                    name: item["name"] as? String ?? "",
                                                    quantity: item["quantity"] as? Double ?? 0,
                                                    total: item["total"] as? Double ?? 0,
                                                    change: item["change"] as? Double ?? 0,
                                                    c: item["c"] as? Double ?? 0)
                            }
                        }
                    }
                }
                
        }
        }
        .background(Color(.white))
    }
}

struct Toast<Presenting, Content>: View where Presenting: View, Content: View {
    @Binding var isPresented: Bool
    let presenter: () -> Presenting
    let content: () -> Content
    let delay: TimeInterval = 2
    
    var body: some View {
        if self.isPresented {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                withAnimation {
                    self.isPresented = false
                }
            }
        }
        
        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                self.presenter()
                
                ZStack {
                    Capsule()
                        .fill(Color.gray)
                    
                    self.content()
                } //ZStack (inner)
                .frame(width: geometry.size.width / 1.25, height: geometry.size.height / 10)
                .opacity(self.isPresented ? 1 : 0)
            } //ZStack (outer)
            .padding(.bottom)
        } //GeometryReader
    } //body
} //Toast

extension View {
    func toast<Content>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View where Content: View {
        Toast(
            isPresented: isPresented,
            presenter: { self },
            content: content
        )
    }
}

#Preview {
ContentView()
//    SearchView(ticker: "AAPL", money: 25000.00)
}
