import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

import java.io.IOException;

public class Main {

    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();

        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }

        return deployment;
    }

    public static void main(String[] args) throws IOException {
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);

        // ""Esper–EPL""

        /*
        // 4. a)
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select irstream data, kursZamkniecia, max(kursZamkniecia) " +
                        "from KursAkcji(spolka = 'Oracle').win:ext_timed(data.getTime(), 7 days)"
        );
//
//        8792: ISTREAM : {data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=12.07, max(kursZamkniecia)=12.07}
//        8794: ISTREAM : {data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=10.92, max(kursZamkniecia)=12.07}
//        8795: ISTREAM : {data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=11.07, max(kursZamkniecia)=12.07}
//        8796: ISTREAM : {data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.46, max(kursZamkniecia)=12.07}
//        8797: ISTREAM : {data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=11.01, max(kursZamkniecia)=11.01}
//        8797: RSTREAM : {data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=12.07, max(kursZamkniecia)=11.01}
//        8797: RSTREAM : {data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=10.92, max(kursZamkniecia)=11.01}
//        8797: RSTREAM : {data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=11.07, max(kursZamkniecia)=11.01}
//        8797: RSTREAM : {data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.46, max(kursZamkniecia)=11.01}
//        8798: ISTREAM : {data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=11.38, max(kursZamkniecia)=11.38}
//        8798: ISTREAM : {data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=11.2, max(kursZamkniecia)=11.38}
//        8799: ISTREAM : {data=Thu Sep 20 00:00:00 CEST 2001, kursZamkniecia=11.31, max(kursZamkniecia)=11.38}
//
//        Dlaczego podkreślone zdarzenia RSTREAM zostały wygenerowane tak późno?
//        Odp.: Zdarzenia RSTREAM zostaly utworzone w momencie, gdy już system wiedział, że upłynął czas okna 7 dni.
//              A system wiedział, bo wpłynęło właśnie zdarzenie opisane znacznikiem czasowym o dacie, która przesuwa
//              okno dalej i już wczesniejsze zdarzenia wypadają.
//
         */


        /*
        // 4. b)
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select irstream data, kursZamkniecia, max(kursZamkniecia) " +
                        "from KursAkcji(spolka = 'Oracle').win:ext_timed_batch(data.getTime(), 7 days)"
        );
//
//        445: ISTREAM : {data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=12.07, max(kursZamkniecia)=12.07}
//        445: ISTREAM : {data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=10.92, max(kursZamkniecia)=12.07}
//        445: ISTREAM : {data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=11.07, max(kursZamkniecia)=12.07}
//        445: ISTREAM : {data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.46, max(kursZamkniecia)=12.07}
//        448: ISTREAM : {data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=11.01, max(kursZamkniecia)=11.38}
//        448: ISTREAM : {data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=11.38, max(kursZamkniecia)=11.38}
//        448: RSTREAM : {data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=12.07, max(kursZamkniecia)=11.38}
//        448: RSTREAM : {data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=10.92, max(kursZamkniecia)=11.38}
//        448: RSTREAM : {data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=11.07, max(kursZamkniecia)=11.38}
//        448: RSTREAM : {data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.46, max(kursZamkniecia)=11.38}
//
//        Gdzie reszta zdarzeń ISTREAM? Gdzie reszta zdarzeń RSTREAM?
//        Odp.: Okno jest wsadowe, a to oznacza, że dopiero po upłynięciu określonego czasu zebrane na nowo zdarzenia
//        sa wstawiane (ISTREAM) w miejsce poprzednio zebranych, które teraz są usuwane (RSTREAM). Nie ma dwóch zdarzeń
//        ISTREAM z data 19, 20 Sep, bo naleza one do okna, ktore jeszcze trwa i nie nastapilo jeszcze jego zakonczenie.
//
        */


        /*
        // 5.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
                        "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 day)"
        );
//
//        5176: ISTREAM : {spolka=Apple, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=18.55, roznica=81.8}
//        5176: ISTREAM : {spolka=CocaCola, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=50.45, roznica=49.899998}
//        5176: ISTREAM : {spolka=Disney, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=25.36, roznica=74.99}
//        5176: ISTREAM : {spolka=Ford, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=19.97, roznica=80.38}
//        5176: ISTREAM : {spolka=Honda, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=73.37, roznica=26.979996}
//        5176: ISTREAM : {spolka=IBM, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=100.35, roznica=0.0}
//        5176: ISTREAM : {spolka=Intel, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=27.47, roznica=72.88}
//        5176: ISTREAM : {spolka=Microsoft, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=57.74, roznica=42.609997}
//        5176: ISTREAM : {spolka=Oracle, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=12.07, roznica=88.28}
//        5176: ISTREAM : {spolka=PepsiCo, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=47.8, roznica=52.55}
//        5176: ISTREAM : {spolka=Yahoo, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=10.64, roznica=89.71}
//        5180: ISTREAM : {spolka=Apple, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=17.72, roznica=80.28}
//        5180: ISTREAM : {spolka=CocaCola, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=49.51, roznica=48.49}
//        5180: ISTREAM : {spolka=Disney, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=24.49, roznica=73.51}
//        5180: ISTREAM : {spolka=Ford, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=19.4, roznica=78.6}
//        5180: ISTREAM : {spolka=Honda, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=77.35, roznica=20.650002}
//        5180: ISTREAM : {spolka=IBM, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=98.0, roznica=0.0}
//        5180: ISTREAM : {spolka=Intel, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=26.1, roznica=71.9}
//        5180: ISTREAM : {spolka=Microsoft, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=56.02, roznica=41.98}
//        5180: ISTREAM : {spolka=Oracle, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=10.92, roznica=87.08}
//        5180: ISTREAM : {spolka=PepsiCo, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=47.1, roznica=50.9}
//        5180: ISTREAM : {spolka=Yahoo, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=11.1, roznica=86.9}
//        5183: ISTREAM : {spolka=Apple, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=17.28, roznica=79.31}
//        5183: ISTREAM : {spolka=CocaCola, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=49.73, roznica=46.859997}
//        5183: ISTREAM : {spolka=Disney, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=24.11, roznica=72.479996}
//        5183: ISTREAM : {spolka=Ford, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=18.76, roznica=77.829994}
//        5183: ISTREAM : {spolka=Honda, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=78.4, roznica=18.189995}
//        5183: ISTREAM : {spolka=IBM, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=96.59, roznica=0.0}
//        5183: ISTREAM : {spolka=Intel, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=25.89, roznica=70.7}
//        5183: ISTREAM : {spolka=Microsoft, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=55.4, roznica=41.189995}
//        5183: ISTREAM : {spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=11.07, roznica=85.52}
//        5183: ISTREAM : {spolka=PepsiCo, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=47.4, roznica=49.189995}
//        5183: ISTREAM : {spolka=Yahoo, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=10.75, roznica=85.84}
//        5186: ISTREAM : {spolka=Apple, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=17.37, roznica=79.1}
//        5186: ISTREAM : {spolka=CocaCola, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=49.95, roznica=46.52}
//        5186: ISTREAM : {spolka=Disney, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=23.58, roznica=72.89}
//        5186: ISTREAM : {spolka=Ford, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=19.4, roznica=77.07}
//        5186: ISTREAM : {spolka=Honda, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=80.12, roznica=16.349998}
//        5186: ISTREAM : {spolka=IBM, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=96.47, roznica=0.0}
//        5186: ISTREAM : {spolka=Intel, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=26.07, roznica=70.4}
//        5186: ISTREAM : {spolka=Microsoft, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=57.58, roznica=38.89}
//        5186: ISTREAM : {spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.46, roznica=85.01}
//        5186: ISTREAM : {spolka=PepsiCo, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=46.9, roznica=49.57}
//        5186: ISTREAM : {spolka=Yahoo, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.74, roznica=84.73}
//        5188: ISTREAM : {spolka=Apple, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=16.99, roznica=76.35}
//        5188: ISTREAM : {spolka=CocaCola, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=50.2, roznica=43.139996}
//        5188: ISTREAM : {spolka=Disney, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=19.25, roznica=74.09}
//        5188: ISTREAM : {spolka=Ford, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=16.55, roznica=76.78999}
//        5188: ISTREAM : {spolka=Honda, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=69.75, roznica=23.589996}
//        5188: ISTREAM : {spolka=IBM, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=93.34, roznica=0.0}
//        5188: ISTREAM : {spolka=Intel, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=23.59, roznica=69.75}
//        5188: ISTREAM : {spolka=Microsoft, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=52.91, roznica=40.429996}
//        5188: ISTREAM : {spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=11.01, roznica=82.329994}
//        5188: ISTREAM : {spolka=PepsiCo, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=47.9, roznica=45.439995}
//        5188: ISTREAM : {spolka=Yahoo, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=10.88, roznica=82.46}
//        5190: ISTREAM : {spolka=Apple, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=16.28, roznica=80.12}
//        5190: ISTREAM : {spolka=CocaCola, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=49.47, roznica=46.93}
//        5190: ISTREAM : {spolka=Disney, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=18.4, roznica=78.0}
//        5190: ISTREAM : {spolka=Ford, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=16.93, roznica=79.47}
//        5190: ISTREAM : {spolka=Honda, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=65.5, roznica=30.900002}
//        5190: ISTREAM : {spolka=IBM, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=96.4, roznica=0.0}
//        5190: ISTREAM : {spolka=Intel, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=23.47, roznica=72.93}
//        5190: ISTREAM : {spolka=Microsoft, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=54.32, roznica=42.08}
//        5190: ISTREAM : {spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=11.38, roznica=85.020004}
//        5190: ISTREAM : {spolka=PepsiCo, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=49.5, roznica=46.9}
//        5190: ISTREAM : {spolka=Yahoo, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=10.1, roznica=86.3}
//        5192: ISTREAM : {spolka=Apple, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=17.02, roznica=78.979996}
//        5192: ISTREAM : {spolka=CocaCola, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=49.5, roznica=46.5}
//        5192: ISTREAM : {spolka=Disney, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=18.5, roznica=77.5}
//        5192: ISTREAM : {spolka=Ford, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=16.43, roznica=79.57}
//        5192: ISTREAM : {spolka=Honda, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=64.25, roznica=31.75}
//        5192: ISTREAM : {spolka=IBM, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=96.0, roznica=0.0}
//        5192: ISTREAM : {spolka=Intel, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=22.28, roznica=73.72}
//        5192: ISTREAM : {spolka=Microsoft, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=53.87, roznica=42.13}
//        5192: ISTREAM : {spolka=Oracle, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=11.2, roznica=84.8}
//        5192: ISTREAM : {spolka=PepsiCo, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=49.59, roznica=46.41}
//        5192: ISTREAM : {spolka=Yahoo, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=10.07, roznica=85.93}
//
        */


        /*
        // 6.
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
                        "from KursAkcji(spolka in ('IBM', 'Honda', 'Microsoft')).win:ext_timed_batch(data.getTime(), 1 day)"
        );
//
//        6398: ISTREAM : {spolka=Honda, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=73.37, roznica=26.979996}
//        6398: ISTREAM : {spolka=IBM, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=100.35, roznica=0.0}
//        6398: ISTREAM : {spolka=Microsoft, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=57.74, roznica=42.609997}
//        6401: ISTREAM : {spolka=Honda, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=77.35, roznica=20.650002}
//        6401: ISTREAM : {spolka=IBM, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=98.0, roznica=0.0}
//        6401: ISTREAM : {spolka=Microsoft, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=56.02, roznica=41.98}
//        6402: ISTREAM : {spolka=Honda, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=78.4, roznica=18.189995}
//        6402: ISTREAM : {spolka=IBM, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=96.59, roznica=0.0}
//        6402: ISTREAM : {spolka=Microsoft, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=55.4, roznica=41.189995}
//        6403: ISTREAM : {spolka=Honda, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=80.12, roznica=16.349998}
//        6403: ISTREAM : {spolka=IBM, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=96.47, roznica=0.0}
//        6403: ISTREAM : {spolka=Microsoft, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=57.58, roznica=38.89}
//        6404: ISTREAM : {spolka=Honda, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=69.75, roznica=23.589996}
//        6404: ISTREAM : {spolka=IBM, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=93.34, roznica=0.0}
//        6404: ISTREAM : {spolka=Microsoft, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=52.91, roznica=40.429996}
//        6405: ISTREAM : {spolka=Honda, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=65.5, roznica=30.900002}
//        6405: ISTREAM : {spolka=IBM, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=96.4, roznica=0.0}
//        6405: ISTREAM : {spolka=Microsoft, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=54.32, roznica=42.08}
//        6406: ISTREAM : {spolka=Honda, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=64.25, roznica=31.75}
//        6406: ISTREAM : {spolka=IBM, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=96.0, roznica=0.0}
//        6406: ISTREAM : {spolka=Microsoft, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=53.87, roznica=42.13}
//
        */


        /*
        // 7. a)
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, kursZamkniecia, kursOtwarcia " +
                        "from KursAkcji(kursZamkniecia > kursOtwarcia).win:length(1)"
        );
//
//        3093: ISTREAM : {spolka=Apple, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=18.55, kursOtwarcia=18.24}
//        3095: ISTREAM : {spolka=CocaCola, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=50.45, kursOtwarcia=48.8}
//        3096: ISTREAM : {spolka=Intel, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=27.47, kursOtwarcia=26.94}
//        3096: ISTREAM : {spolka=Microsoft, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=57.74, kursOtwarcia=56.18}
//        3096: ISTREAM : {spolka=PepsiCo, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=47.8, kursOtwarcia=47.46}
//        3097: ISTREAM : {spolka=Honda, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=77.35, kursOtwarcia=76.48}
//        3097: ISTREAM : {spolka=Yahoo, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=11.1, kursOtwarcia=11.03}
//        3097: ISTREAM : {spolka=CocaCola, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=49.73, kursOtwarcia=49.26}
//        3097: ISTREAM : {spolka=Disney, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=24.11, kursOtwarcia=24.1}
//        3098: ISTREAM : {spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=11.07, kursOtwarcia=10.86}
//        3098: ISTREAM : {spolka=PepsiCo, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=47.4, kursOtwarcia=46.9}
//        3098: ISTREAM : {spolka=Yahoo, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=10.75, kursOtwarcia=10.74}
//        3099: ISTREAM : {spolka=Apple, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=17.37, kursOtwarcia=17.0}
//        3099: ISTREAM : {spolka=CocaCola, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=49.95, kursOtwarcia=49.74}
//        3099: ISTREAM : {spolka=Disney, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=23.58, kursOtwarcia=23.5}
//        3099: ISTREAM : {spolka=Ford, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=19.4, kursOtwarcia=18.7}
//        3099: ISTREAM : {spolka=Honda, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=80.12, kursOtwarcia=78.57}
//        3099: ISTREAM : {spolka=IBM, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=96.47, kursOtwarcia=96.0}
//        3100: ISTREAM : {spolka=Intel, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=26.07, kursOtwarcia=25.53}
//        3100: ISTREAM : {spolka=Microsoft, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=57.58, kursOtwarcia=54.92}
//        3100: ISTREAM : {spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.46, kursOtwarcia=10.89}
//        3100: ISTREAM : {spolka=Yahoo, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.74, kursOtwarcia=10.73}
//        3101: ISTREAM : {spolka=Apple, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=16.99, kursOtwarcia=16.0}
//        3101: ISTREAM : {spolka=CocaCola, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=50.2, kursOtwarcia=49.5}
//        3101: ISTREAM : {spolka=Disney, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=19.25, kursOtwarcia=19.0}
//        3101: ISTREAM : {spolka=Honda, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=69.75, kursOtwarcia=66.25}
//        3102: ISTREAM : {spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=11.01, kursOtwarcia=10.29}
//        3102: ISTREAM : {spolka=PepsiCo, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=47.9, kursOtwarcia=47.15}
//        3102: ISTREAM : {spolka=Yahoo, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=10.88, kursOtwarcia=10.55}
//        3102: ISTREAM : {spolka=Ford, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=16.93, kursOtwarcia=16.31}
//        3102: ISTREAM : {spolka=IBM, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=96.4, kursOtwarcia=94.0}
//        3103: ISTREAM : {spolka=Microsoft, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=54.32, kursOtwarcia=53.41}
//        3103: ISTREAM : {spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=11.38, kursOtwarcia=10.95}
//        3103: ISTREAM : {spolka=PepsiCo, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=49.5, kursOtwarcia=48.0}
//        3103: ISTREAM : {spolka=Apple, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=17.02, kursOtwarcia=16.5}
//        3103: ISTREAM : {spolka=Disney, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=18.5, kursOtwarcia=18.25}
//        3104: ISTREAM : {spolka=Honda, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=64.25, kursOtwarcia=64.2}
//        3104: ISTREAM : {spolka=PepsiCo, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=49.59, kursOtwarcia=49.49}
//        3105: ISTREAM : {spolka=Oracle, data=Thu Sep 20 00:00:00 CEST 2001, kursZamkniecia=11.31, kursOtwarcia=10.79}
//        3105: ISTREAM : {spolka=Yahoo, data=Thu Sep 20 00:00:00 CEST 2001, kursZamkniecia=9.97, kursOtwarcia=9.95}
//
        */


        /*
        // 7. b)
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, kursZamkniecia, kursOtwarcia " +
                        "from KursAkcji(KursAkcji.roznicaKursow(kursZamkniecia, kursOtwarcia) > 0).win:length(1)"
        );
//
//        659: ISTREAM : {spolka=Apple, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=18.55, kursOtwarcia=18.24}
//        661: ISTREAM : {spolka=CocaCola, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=50.45, kursOtwarcia=48.8}
//        661: ISTREAM : {spolka=Intel, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=27.47, kursOtwarcia=26.94}
//        662: ISTREAM : {spolka=Microsoft, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=57.74, kursOtwarcia=56.18}
//        662: ISTREAM : {spolka=PepsiCo, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=47.8, kursOtwarcia=47.46}
//        662: ISTREAM : {spolka=Honda, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=77.35, kursOtwarcia=76.48}
//        663: ISTREAM : {spolka=Yahoo, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=11.1, kursOtwarcia=11.03}
//        663: ISTREAM : {spolka=CocaCola, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=49.73, kursOtwarcia=49.26}
//        663: ISTREAM : {spolka=Disney, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=24.11, kursOtwarcia=24.1}
//        664: ISTREAM : {spolka=Oracle, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=11.07, kursOtwarcia=10.86}
//        664: ISTREAM : {spolka=PepsiCo, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=47.4, kursOtwarcia=46.9}
//        664: ISTREAM : {spolka=Yahoo, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=10.75, kursOtwarcia=10.74}
//        665: ISTREAM : {spolka=Apple, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=17.37, kursOtwarcia=17.0}
//        665: ISTREAM : {spolka=CocaCola, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=49.95, kursOtwarcia=49.74}
//        665: ISTREAM : {spolka=Disney, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=23.58, kursOtwarcia=23.5}
//        665: ISTREAM : {spolka=Ford, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=19.4, kursOtwarcia=18.7}
//        665: ISTREAM : {spolka=Honda, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=80.12, kursOtwarcia=78.57}
//        665: ISTREAM : {spolka=IBM, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=96.47, kursOtwarcia=96.0}
//        666: ISTREAM : {spolka=Intel, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=26.07, kursOtwarcia=25.53}
//        666: ISTREAM : {spolka=Microsoft, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=57.58, kursOtwarcia=54.92}
//        666: ISTREAM : {spolka=Oracle, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.46, kursOtwarcia=10.89}
//        666: ISTREAM : {spolka=Yahoo, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=11.74, kursOtwarcia=10.73}
//        667: ISTREAM : {spolka=Apple, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=16.99, kursOtwarcia=16.0}
//        667: ISTREAM : {spolka=CocaCola, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=50.2, kursOtwarcia=49.5}
//        667: ISTREAM : {spolka=Disney, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=19.25, kursOtwarcia=19.0}
//        667: ISTREAM : {spolka=Honda, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=69.75, kursOtwarcia=66.25}
//        667: ISTREAM : {spolka=Oracle, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=11.01, kursOtwarcia=10.29}
//        668: ISTREAM : {spolka=PepsiCo, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=47.9, kursOtwarcia=47.15}
//        668: ISTREAM : {spolka=Yahoo, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=10.88, kursOtwarcia=10.55}
//        668: ISTREAM : {spolka=Ford, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=16.93, kursOtwarcia=16.31}
//        668: ISTREAM : {spolka=IBM, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=96.4, kursOtwarcia=94.0}
//        668: ISTREAM : {spolka=Microsoft, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=54.32, kursOtwarcia=53.41}
//        669: ISTREAM : {spolka=Oracle, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=11.38, kursOtwarcia=10.95}
//        669: ISTREAM : {spolka=PepsiCo, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=49.5, kursOtwarcia=48.0}
//        669: ISTREAM : {spolka=Apple, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=17.02, kursOtwarcia=16.5}
//        669: ISTREAM : {spolka=Disney, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=18.5, kursOtwarcia=18.25}
//        670: ISTREAM : {spolka=Honda, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=64.25, kursOtwarcia=64.2}
//        670: ISTREAM : {spolka=PepsiCo, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=49.59, kursOtwarcia=49.49}
//        671: ISTREAM : {spolka=Oracle, data=Thu Sep 20 00:00:00 CEST 2001, kursZamkniecia=11.31, kursOtwarcia=10.79}
//        671: ISTREAM : {spolka=Yahoo, data=Thu Sep 20 00:00:00 CEST 2001, kursZamkniecia=9.97, kursOtwarcia=9.95}
//
         */


        /*
        // 8
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, kursZamkniecia, (max(kursZamkniecia) - kursZamkniecia) as roznica " +
                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed(data.getTime(), 7 days)"
        );
//
//        605: ISTREAM : {spolka=CocaCola, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=50.45, roznica=0.0}
//        606: ISTREAM : {spolka=PepsiCo, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=47.8, roznica=2.6500015}
//        607: ISTREAM : {spolka=CocaCola, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=49.51, roznica=0.94000244}
//        607: ISTREAM : {spolka=PepsiCo, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=47.1, roznica=3.3500023}
//        607: ISTREAM : {spolka=CocaCola, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=49.73, roznica=0.7200012}
//        608: ISTREAM : {spolka=PepsiCo, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=47.4, roznica=3.0499992}
//        608: ISTREAM : {spolka=CocaCola, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=49.95, roznica=0.5}
//        609: ISTREAM : {spolka=PepsiCo, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=46.9, roznica=3.5499992}
//        609: ISTREAM : {spolka=CocaCola, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=50.2, roznica=0.0}
//        610: ISTREAM : {spolka=PepsiCo, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=47.9, roznica=2.2999992}
//        610: ISTREAM : {spolka=CocaCola, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=49.47, roznica=0.72999954}
//        611: ISTREAM : {spolka=PepsiCo, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=49.5, roznica=0.70000076}
//        611: ISTREAM : {spolka=CocaCola, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=49.5, roznica=0.70000076}
//        611: ISTREAM : {spolka=PepsiCo, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=49.59, roznica=0.6100006}
//        612: ISTREAM : {spolka=CocaCola, data=Thu Sep 20 00:00:00 CEST 2001, kursZamkniecia=48.35, roznica=1.8500023}
//        612: ISTREAM : {spolka=PepsiCo, data=Thu Sep 20 00:00:00 CEST 2001, kursZamkniecia=48.76, roznica=1.4400024}
//
         */


        /*
        // 9
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream data, spolka, kursZamkniecia " +
                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed_batch(data.getTime(), 1 day)" +
                        "having kursZamkniecia = max(kursZamkniecia)"
        );
//
//        9044: ISTREAM : {spolka=CocaCola, data=Wed Sep 05 00:00:00 CEST 2001, kursZamkniecia=50.45}
//        9046: ISTREAM : {spolka=CocaCola, data=Thu Sep 06 00:00:00 CEST 2001, kursZamkniecia=49.51}
//        9047: ISTREAM : {spolka=CocaCola, data=Fri Sep 07 00:00:00 CEST 2001, kursZamkniecia=49.73}
//        9048: ISTREAM : {spolka=CocaCola, data=Mon Sep 10 00:00:00 CEST 2001, kursZamkniecia=49.95}
//        9049: ISTREAM : {spolka=CocaCola, data=Mon Sep 17 00:00:00 CEST 2001, kursZamkniecia=50.2}
//        9050: ISTREAM : {spolka=PepsiCo, data=Tue Sep 18 00:00:00 CEST 2001, kursZamkniecia=49.5}
//        9051: ISTREAM : {spolka=PepsiCo, data=Wed Sep 19 00:00:00 CEST 2001, kursZamkniecia=49.59}
//
        */


        /*
        // 10
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select istream max(kursZamkniecia) " +
                        "from KursAkcji().win:ext_timed_batch(data.getTime(), 7 days)"
        );
//
//        1999: ISTREAM : {max(kursZamkniecia)=100.35}
//        1999: ISTREAM : {max(kursZamkniecia)=96.4}
//
        */


        /*
        // 11
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select cc.kursZamkniecia as kursCoc, pc.data as data, pc.kursZamkniecia as kursPep " +
                        "from KursAkcji(spolka = 'CocaCola').win:ext_timed(data.getTime(), 1 day) as cc " +
                        "join KursAkcji(spolka = 'PepsiCo').win:ext_timed(data.getTime(), 1 day) as pc " +
                        "on cc.data = pc.data " +
                        "where pc.kursZamkniecia > cc.kursZamkniecia"
        );
//
//        5776: ISTREAM : {kursCoc=49.47, data=Tue Sep 18 00:00:00 CEST 2001, kursPep=49.5}
//        5776: ISTREAM : {kursCoc=49.5, data=Wed Sep 19 00:00:00 CEST 2001, kursPep=49.59}
//        5776: ISTREAM : {kursCoc=48.35, data=Thu Sep 20 00:00:00 CEST 2001, kursPep=48.76}
//
        */


        /*
        // 12
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select k.data, k.kursZamkniecia as kursBiezacy, k.spolka, (k.kursZamkniecia - f.kursZamkniecia) as roznica " +
                        "from KursAkcji(spolka in ('CocaCola', 'PepsiCo')).win:length(1) as k " +
                        "join KursAkcji(spolka in ('CocaCola', 'PepsiCo')).std:firstunique(spolka) as f " +
                        "on k.spolka = f.spolka"
        );
//
//        2204: ISTREAM : {k.data=Wed Sep 05 00:00:00 CEST 2001, kursBiezacy=50.45, k.spolka=CocaCola, roznica=0.0}
//        2207: ISTREAM : {k.data=Wed Sep 05 00:00:00 CEST 2001, kursBiezacy=47.8, k.spolka=PepsiCo, roznica=0.0}
//        2208: ISTREAM : {k.data=Thu Sep 06 00:00:00 CEST 2001, kursBiezacy=49.51, k.spolka=CocaCola, roznica=-0.94000244}
//        2209: ISTREAM : {k.data=Thu Sep 06 00:00:00 CEST 2001, kursBiezacy=47.1, k.spolka=PepsiCo, roznica=-0.70000076}
//        2209: ISTREAM : {k.data=Fri Sep 07 00:00:00 CEST 2001, kursBiezacy=49.73, k.spolka=CocaCola, roznica=-0.7200012}
//        2210: ISTREAM : {k.data=Fri Sep 07 00:00:00 CEST 2001, kursBiezacy=47.4, k.spolka=PepsiCo, roznica=-0.3999977}
//        2211: ISTREAM : {k.data=Mon Sep 10 00:00:00 CEST 2001, kursBiezacy=49.95, k.spolka=CocaCola, roznica=-0.5}
//        2212: ISTREAM : {k.data=Mon Sep 10 00:00:00 CEST 2001, kursBiezacy=46.9, k.spolka=PepsiCo, roznica=-0.8999977}
//        2213: ISTREAM : {k.data=Mon Sep 17 00:00:00 CEST 2001, kursBiezacy=50.2, k.spolka=CocaCola, roznica=-0.25}
//        2214: ISTREAM : {k.data=Mon Sep 17 00:00:00 CEST 2001, kursBiezacy=47.9, k.spolka=PepsiCo, roznica=0.10000229}
//        2215: ISTREAM : {k.data=Tue Sep 18 00:00:00 CEST 2001, kursBiezacy=49.47, k.spolka=CocaCola, roznica=-0.97999954}
//        2215: ISTREAM : {k.data=Tue Sep 18 00:00:00 CEST 2001, kursBiezacy=49.5, k.spolka=PepsiCo, roznica=1.7000008}
//        2216: ISTREAM : {k.data=Wed Sep 19 00:00:00 CEST 2001, kursBiezacy=49.5, k.spolka=CocaCola, roznica=-0.95000076}
//        2217: ISTREAM : {k.data=Wed Sep 19 00:00:00 CEST 2001, kursBiezacy=49.59, k.spolka=PepsiCo, roznica=1.7900009}
//        2218: ISTREAM : {k.data=Thu Sep 20 00:00:00 CEST 2001, kursBiezacy=48.35, k.spolka=CocaCola, roznica=-2.1000023}
//        2219: ISTREAM : {k.data=Thu Sep 20 00:00:00 CEST 2001, kursBiezacy=48.76, k.spolka=PepsiCo, roznica=0.9599991}
//
        */


        /*
        // 13
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select k.data, k.kursZamkniecia as kursBiezacy, k.spolka, (k.kursZamkniecia - f.kursZamkniecia) as roznica " +
                        "from KursAkcji.win:length(1) as k " +
                        "join KursAkcji.std:firstunique(spolka) as f " +
                        "on k.spolka = f.spolka " +
                        "where k.kursZamkniecia > f.kursZamkniecia"
        );
//
//        6078: ISTREAM : {k.data=Thu Sep 06 00:00:00 CEST 2001, kursBiezacy=77.35, k.spolka=Honda, roznica=3.9799957}
//        6081: ISTREAM : {k.data=Thu Sep 06 00:00:00 CEST 2001, kursBiezacy=11.1, k.spolka=Yahoo, roznica=0.46000004}
//        6082: ISTREAM : {k.data=Fri Sep 07 00:00:00 CEST 2001, kursBiezacy=78.4, k.spolka=Honda, roznica=5.029999}
//        6083: ISTREAM : {k.data=Fri Sep 07 00:00:00 CEST 2001, kursBiezacy=10.75, k.spolka=Yahoo, roznica=0.10999966}
//        6084: ISTREAM : {k.data=Mon Sep 10 00:00:00 CEST 2001, kursBiezacy=80.12, k.spolka=Honda, roznica=6.75}
//        6086: ISTREAM : {k.data=Mon Sep 10 00:00:00 CEST 2001, kursBiezacy=11.74, k.spolka=Yahoo, roznica=1.0999994}
//        6089: ISTREAM : {k.data=Mon Sep 17 00:00:00 CEST 2001, kursBiezacy=47.9, k.spolka=PepsiCo, roznica=0.10000229}
//        6089: ISTREAM : {k.data=Mon Sep 17 00:00:00 CEST 2001, kursBiezacy=10.88, k.spolka=Yahoo, roznica=0.23999977}
//        6091: ISTREAM : {k.data=Tue Sep 18 00:00:00 CEST 2001, kursBiezacy=49.5, k.spolka=PepsiCo, roznica=1.7000008}
//        6093: ISTREAM : {k.data=Wed Sep 19 00:00:00 CEST 2001, kursBiezacy=49.59, k.spolka=PepsiCo, roznica=1.7900009}
//        6095: ISTREAM : {k.data=Thu Sep 20 00:00:00 CEST 2001, kursBiezacy=48.76, k.spolka=PepsiCo, roznica=0.9599991}
//
        */


        /*
        // 14
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select k.spolka, k.data as dataA, f.data as dataB, k.kursOtwarcia as kursA, f.kursOtwarcia as kursB " +
                        "from KursAkcji.win:length(1) as k " +
                        "join KursAkcji.win:ext_timed(data.getTime(), 7 days) as f " +
                        "on k.spolka = f.spolka " +
                        "where k.kursOtwarcia + 3 < f.kursOtwarcia " +
                        "or k.kursOtwarcia > f.kursOtwarcia + 3"
        );
//
//        5745: ISTREAM : {dataA=Fri Sep 07 00:00:00 CEST 2001, k.spolka=Honda, kursA=80.1, kursB=73.5, dataB=Wed Sep 05 00:00:00 CEST 2001}
//        5745: ISTREAM : {dataA=Fri Sep 07 00:00:00 CEST 2001, k.spolka=Honda, kursA=80.1, kursB=76.48, dataB=Thu Sep 06 00:00:00 CEST 2001}
//        5748: ISTREAM : {dataA=Fri Sep 07 00:00:00 CEST 2001, k.spolka=IBM, kursA=97.9, kursB=101.5, dataB=Wed Sep 05 00:00:00 CEST 2001}
//        5751: ISTREAM : {dataA=Mon Sep 10 00:00:00 CEST 2001, k.spolka=Honda, kursA=78.57, kursB=73.5, dataB=Wed Sep 05 00:00:00 CEST 2001}
//        5751: ISTREAM : {dataA=Mon Sep 10 00:00:00 CEST 2001, k.spolka=IBM, kursA=96.0, kursB=101.5, dataB=Wed Sep 05 00:00:00 CEST 2001}
//        5751: ISTREAM : {dataA=Mon Sep 10 00:00:00 CEST 2001, k.spolka=IBM, kursA=96.0, kursB=100.68, dataB=Thu Sep 06 00:00:00 CEST 2001}
//        5760: ISTREAM : {dataA=Thu Sep 20 00:00:00 CEST 2001, k.spolka=Honda, kursA=61.99, kursB=66.25, dataB=Mon Sep 17 00:00:00 CEST 2001}
//        5760: ISTREAM : {dataA=Thu Sep 20 00:00:00 CEST 2001, k.spolka=Honda, kursA=61.99, kursB=65.5, dataB=Tue Sep 18 00:00:00 CEST 2001}
//
        */


        /*
        // 15
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select data, spolka, obrot " +
                        "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
                        "order by obrot desc " +
                        "limit 3"
        );
//
//        6697: ISTREAM : {spolka=Ford, data=Fri Sep 07 00:00:00 CEST 2001, obrot=9270400.0}
//        6697: ISTREAM : {spolka=Disney, data=Fri Sep 07 00:00:00 CEST 2001, obrot=8694600.0}
//        6697: ISTREAM : {spolka=Ford, data=Thu Sep 06 00:00:00 CEST 2001, obrot=8138500.0}
//        6700: ISTREAM : {spolka=Disney, data=Mon Sep 17 00:00:00 CEST 2001, obrot=4.62337E7}
//        6700: ISTREAM : {spolka=Disney, data=Tue Sep 18 00:00:00 CEST 2001, obrot=2.31388E7}
//        6700: ISTREAM : {spolka=PepsiCo, data=Tue Sep 18 00:00:00 CEST 2001, obrot=1.85115E7}
//
        */



        // 16
        EPDeployment deployment = compileAndDeploy(
                epRuntime,
                "select data, spolka, obrot " +
                        "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
                        "order by obrot desc " +
                        "limit 1 offset 2"
        );
//
//        3525: ISTREAM : {spolka=Ford, data=Thu Sep 06 00:00:00 CEST 2001, obrot=8138500.0}
//        3528: ISTREAM : {spolka=PepsiCo, data=Tue Sep 18 00:00:00 CEST 2001, obrot=1.85115E7}
//



        ProstyListener prostyListener = new ProstyListener();
        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }

        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }
}
